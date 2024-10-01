//
//  ContactViewModel.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 13.09.24.
//

import FirebaseFirestore

@Observable class ContactViewModel {
    var pendingRequests: [ContactRequest] = [] {
        didSet {
            // Aktualisiere die Anzeige, wenn sich die Anzahl der neuen Anfragen ändert
            self.newRequestCount = self.pendingRequests.count
            self.showSheet = self.newRequestCount > 0
        }
    }
    var acceptedContacts: [Contact] = []
    var newRequestCount: Int = 0
    
    var showSheet = false
    var alertMessage: String?
    var sendToken: String = ""
    var errorMessage: String?
    private var manager: ContactManagerProtocol
    
    private var listener: ListenerRegistration?
    private var acceptedContactsListener: ListenerRegistration?
    
    init(manager: ContactManagerProtocol) {
        self.manager = manager
        setupListener()
        setupAcceptedContactsListener()
    }
    
    func setupListener() {
        listener = Firestore.firestore().collection("ContactRequests")
            .whereField("to", isEqualTo: AuthServiceManager.shared.user?.uid ?? "")
            .whereField("status", isEqualTo: RequestStatus.pending.rawValue)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self.pendingRequests = documents.compactMap { try? $0.data(as: ContactRequest.self) }
                self.newRequestCount = self.pendingRequests.count
                self.showAlertForNewRequests()
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
                try await manager.sendContactRequest(to: sendToken)
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
                setupListener()
            } catch {
                self.errorMessage = "Error updating request status: \(error.localizedDescription)"
                print(self.errorMessage ?? "")
            }
        }
    }
    
    func blockContact(contactID: String) {
        Task {
            do {
                try await manager.blockContact(to: contactID)
                print("Contact blocked successfully")
                // Listener neu starten, um die Liste der ausstehenden Anfragen zu aktualisieren
                setupListener()
            } catch {
                self.errorMessage = "Error blocking contact: \(error.localizedDescription)"
                print(self.errorMessage ?? "")
            }
        }
    }
    
    
    func showAlertForNewRequests() {
        // Logik zum Anzeigen des Alerts für neue Anfragen
        if let request = pendingRequests.first(where: { $0.status == .pending }) {
            self.alertMessage = "Do you want to accept the request from \(request.from)?"
            self.showSheet = true
        }
    }
    
    
    deinit {
        listener?.remove()
        acceptedContactsListener?.remove()
    }
}
