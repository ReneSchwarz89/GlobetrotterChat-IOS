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
    private let db = Firestore.firestore()
    private var manager: ProfileProtocol
    var contact: Contact?
    
    private var listener: ListenerRegistration?
    private var acceptedContactsListener: ListenerRegistration?

    init(manager: ProfileProtocol) {
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
            acceptedContactsListener = Firestore.firestore().collection("Contact").document(AuthServiceManager.shared.user?.uid ?? "").collection("AcceptedContacts")
                .addSnapshotListener { snapshot, error in
                    guard let documents = snapshot?.documents else { return }
                    self.acceptedContacts = documents.compactMap { try? $0.data(as: Contact.self) }
                }
        }
        
        func sendContactRequest() {
            Task {
                do {
                    let request = ContactRequest(from: AuthServiceManager.shared.user?.uid ?? "", to: token, status: .pending)
                    
                    try await db.collection("ContactRequests").addDocument(data: request.toDictionary())
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
                    let query = db.collection("ContactRequests")
                        .whereField("from", isEqualTo: request.from)
                        .whereField("to", isEqualTo: request.to)
                        .whereField("status", isEqualTo: RequestStatus.pending.rawValue)
                    
                    let snapshot = try await query.getDocuments()
                    guard let document = snapshot.documents.first else { return }
                    
                    try await document.reference.updateData(["status": newStatus.rawValue])
                    print("Request status updated successfully")
                    
                    if newStatus == .allowed {
                        addAcceptedContact(from: request.from)
                        addAcceptedContact(to: request.to)
                    }
                } catch {
                    self.errorMessage = "Error updating request status: \(error.localizedDescription)"
                    print(self.errorMessage ?? "")
                }
            }
        }
        
        private func addAcceptedContact(from uid: String) {
            Task {
                do {
                    
                    let document = try await db.collection("Contacts").document(uid).getDocument()
                    if let contact = try document.data(as: Contact?.self) {
                        acceptedContacts.append(contact)
                        saveAcceptedContact(contact)
                    } else {
                        print("No contact found for uid: \(uid)")
                    }
                } catch {
                    self.errorMessage = "Error adding accepted contact: \(error.localizedDescription)"
                    print(self.errorMessage ?? "")
                }
            }
        }
        
    
    private func addAcceptedContact(to uid: String) {
        Task {
            do {
                let document = try await db.collection("Contacts").document(uid).getDocument()
                if let contact = try document.data(as: Contact?.self) {
                    saveAcceptedContact(contact, for: uid)
                } else {
                    print("No contact found for uid: \(uid)")
                }
            } catch {
                self.errorMessage = "Error adding accepted contact: \(error.localizedDescription)"
                print(self.errorMessage ?? "")
            }
        }
    }
    private func saveAcceptedContact(_ contact: Contact, for uid: String? = nil) {
            Task {
                do {
                    let userId = uid ?? AuthServiceManager.shared.user?.uid ?? ""
                    try await db.collection("Contact").document(userId).collection("AcceptedContacts").document(contact.contactID).setData(contact.toDictionary())
                    print("Accepted contact saved successfully")
                } catch {
                    self.errorMessage = "Error saving accepted contact: \(error.localizedDescription)"
                    print(self.errorMessage ?? "")
                }
            }
        }
        
    
    deinit {
        listener?.remove()
        acceptedContactsListener?.remove()
    }
}
