//
//  ContactViewModel.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 13.09.24.
//

import FirebaseFirestore

@Observable class ContactViewModel {
    var pendingRequests: [ContactRequest] = []
    var acceptedContacts: [Contact] = []
    var newRequestCount: Int = 0
    var token: String = ""
    var errorMessage: String?
    private var manager: ContactManagerProtocol
    
    private var listener: ListenerRegistration?
    private var acceptedContactsListener: ListenerRegistration?

    init(manager: ContactManagerProtocol) {
        self.manager = manager
        setupListener()
        setupAcceptedContactsListener()
    }
    
    private func setupListener() {
        listener = Firestore.firestore().collection("ContactRequests")
            .whereField("to", isEqualTo: AuthServiceManager.shared.user?.uid ?? "")
            .whereField("status", isEqualTo: RequestStatus.pending.rawValue)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self.pendingRequests = documents.compactMap { try? $0.data(as: ContactRequest.self) }
                self.newRequestCount = self.pendingRequests.count
            }
    }
    
    private func setupAcceptedContactsListener() {
        acceptedContactsListener = Firestore.firestore().collection("Contacts").document(AuthServiceManager.shared.user?.uid ?? "").collection("AcceptedContacts")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self.acceptedContacts = documents.compactMap { try? $0.data(as: Contact.self) }
            }
    }
    
    func sendContactRequest() {
        Task {
            do {
                try await manager.sendContactRequest(from: AuthServiceManager.shared.user?.uid ?? "", to: token)
                print("Request sent successfully")
            } catch {
                self.errorMessage = "Error sending request: \(error.localizedDescription)"
                print(self.errorMessage ?? "")
            }
        }
    }
    
    func updateRequestStatus(request: ContactRequest, to newStatus: RequestStatus) {
        Task {
            do {
                try await manager.updateRequestStatus(request: request, to: newStatus)
                print("Request status updated successfully")
            } catch {
                self.errorMessage = "Error updating request status: \(error.localizedDescription)"
                print(self.errorMessage ?? "")
            }
        }
    }
    
    deinit {
        listener?.remove()
        acceptedContactsListener?.remove()
    }
}
