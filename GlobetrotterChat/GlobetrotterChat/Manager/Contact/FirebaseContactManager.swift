
//
//  FirebaseContactManager.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 26.09.24.
//

import Foundation
import FirebaseFirestore
import Observation

class FirebaseContactManager: ContactManagerProtocol {
    
    var uid: String
    
    private var db = Firestore.firestore()
    private var pendingRequestsListener: ListenerRegistration?
    private var acceptedContactsListener: ListenerRegistration?
    private var blockedContactsListener: ListenerRegistration?
    
    init() {
        self.uid = AuthServiceManager.shared.userID ?? ""
    }
    
    func setPendingRequestsListener(completion: @escaping ([ContactRequest]) -> Void) {
        pendingRequestsListener = db.collection("ContactRequests")
            .whereField("to", isEqualTo: uid)
            .whereField("status", isEqualTo: RequestStatus.pending.rawValue)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let requests = documents.compactMap { try? $0.data(as: ContactRequest.self) }
                completion(requests)
            }
    }
    
    func setAcceptedContactsListener(completion: @escaping ([Contact]) -> Void) {
        acceptedContactsListener = db.collection("Contacts").document(uid).collection("ContactRelations")
            .document("relations")
            .addSnapshotListener { snapshot, error in
                guard let document = snapshot, let contactRelations = try? document.data(as: ContactRelations.self) else {
                    completion([])
                    return
                }
                
                var contacts: [Contact] = []
                let group = DispatchGroup()
                
                for contactID in contactRelations.acceptedContactIDs {
                    group.enter()
                    self.db.collection("Contacts").document(contactID).getDocument { document, error in
                        if let document = document, let contact = try? document.data(as: Contact.self) {
                            contacts.append(contact)
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    completion(contacts)
                }
            }
    }
    
    func setBlockedContactsListener(completion: @escaping ([Contact]) -> Void) {
        blockedContactsListener = db.collection("Contacts").document(uid).collection("ContactRelations")
            .document("relations")
            .addSnapshotListener { snapshot, error in
                guard let document = snapshot, let contactRelations = try? document.data(as: ContactRelations.self) else {
                    completion([])
                    return
                }
                
                var contacts: [Contact] = []
                let group = DispatchGroup()
                
                for contactID in contactRelations.blockedContactIDs {
                    group.enter()
                    self.db.collection("Contacts").document(contactID).getDocument { document, error in
                        if let document = document, let contact = try? document.data(as: Contact.self) {
                            contacts.append(contact)
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    completion(contacts)
                }
            }
    }
    
    func removeListeners() {
        pendingRequestsListener?.remove()
        acceptedContactsListener?.remove()
        blockedContactsListener?.remove()
    }
    
    func sendContactRequest(to: String) async throws {
        let requestID = "\(uid)_\(to)"
        let request = ContactRequest(from: uid, to: to, status: .pending)
        try await db.collection("ContactRequests").document(requestID).setData(request.toDictionary())
    }
    
    func updateRequestStatus(request: ContactRequest, to newStatus: RequestStatus) async throws {
        let requestID1 = "\(request.from)_\(request.to)"
        let requestID2 = "\(request.to)_\(request.from)"
        
        var document = db.collection("ContactRequests").document(requestID1)
        var docSnapshot = try await document.getDocument()
        
        if !docSnapshot.exists {
            document = db.collection("ContactRequests").document(requestID2)
            docSnapshot = try await document.getDocument()
            
            if !docSnapshot.exists {
                print("Request not found")
                return
            }
        }
        
        try await document.updateData(["status": newStatus.rawValue])
        print("Updated request status to \(newStatus.rawValue) for request \(request.id)")
        
        switch newStatus {
        case .allowed:
            try await addAcceptedContact(uid: request.to, contactID: request.from)
            try await addAcceptedContact(uid: request.from, contactID: request.to)
            try await removeBlockedContact(uid: request.to, contactID: request.from)
            try await removeBlockedContact(uid: request.from, contactID: request.to)
            
            try await FirebaseChatGroupsManager.shared.updateChatGroupActivity(for: request.from, contactID: request.to, isActive: true)
        case .blocked:
            try await removeAcceptedContact(uid: request.to, contactID: request.from)
            try await removeAcceptedContact(uid: request.from, contactID: request.to)
            try await addBlockedContact(contactID: request.from == self.uid ? request.to : request.from)
            
            try await FirebaseChatGroupsManager.shared.updateChatGroupActivity(for: request.from, contactID: request.to, isActive: false)
        default:
            break
        }
    }
    
    func addAcceptedContact(uid: String, contactID: String) async throws {
        var contactRelations = try await getContactRelations(uid: uid)
        if !contactRelations.acceptedContactIDs.contains(contactID) {
            contactRelations.acceptedContactIDs.append(contactID)
        }
        try await saveContactRelations(uid: uid, contactRelations: contactRelations)
        print("Added \(contactID) to accepted contacts for \(uid)")
    }
    
    func removeAcceptedContact(uid: String, contactID: String) async throws {
        var contactRelations = try await getContactRelations(uid: uid)
        contactRelations.acceptedContactIDs.removeAll { $0 == contactID }
        try await saveContactRelations(uid: uid, contactRelations: contactRelations)
        print("Removed \(contactID) from accepted contacts for \(uid)")
    }
    
    
    func addBlockedContact(contactID: String) async throws {
        let uid = self.uid // Verwende die uid des eingeloggten Nutzers
        var contactRelations = try await getContactRelations(uid: uid)
        if !contactRelations.blockedContactIDs.contains(contactID) {
            contactRelations.blockedContactIDs.append(contactID)
        }
        try await saveContactRelations(uid: uid, contactRelations: contactRelations)
        print("Added \(contactID) to blocked contacts for \(String(describing: uid))")
    }
    
    func removeBlockedContact(uid: String, contactID: String) async throws {
        var contactRelations = try await getContactRelations(uid: uid)
        contactRelations.blockedContactIDs.removeAll { $0 == contactID }
        try await saveContactRelations(uid: uid, contactRelations: contactRelations)
        print("Removed \(contactID) from blocked contacts for \(uid)")
    }
    
    func getContactRelations(uid: String) async throws -> ContactRelations {
        let document = try await db.collection("Contacts").document(uid).collection("ContactRelations").document("relations").getDocument()
        if let contactRelations = try? document.data(as: ContactRelations.self) {
            return contactRelations
        } else {
            return ContactRelations()
        }
    }
    
    func saveContactRelations(uid: String, contactRelations: ContactRelations) async throws {
        try await db.collection("Contacts").document(uid).collection("ContactRelations").document("relations").setData(contactRelations.toDictionary())
    }
}
