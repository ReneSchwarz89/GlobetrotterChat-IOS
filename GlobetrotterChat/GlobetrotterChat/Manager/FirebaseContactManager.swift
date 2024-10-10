
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
    
    private var db = Firestore.firestore()
    private let uid: String
    private var pendingRequestsListener: ListenerRegistration?
    private var acceptedContactsListener: ListenerRegistration?
    
    init(uid: String) {
        self.uid = uid
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
        acceptedContactsListener = db.collection("ContactRelations").document(uid)
            .addSnapshotListener { snapshot, error in
                guard let document = snapshot, let data = document.data(), let acceptedContactIDs = data["acceptedContactIDs"] as? [String] else { return }
                
                var contacts: [Contact] = []
                let group = DispatchGroup()
                
                for contactID in acceptedContactIDs {
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
        
        switch newStatus {
        case .allowed:
            try await addAcceptedContact(uid: request.to, contactID: request.from)
            try await addAcceptedContact(uid: request.from, contactID: request.to)
        case .blocked:
            try await removeAcceptedContact(uid: request.to, contactID: request.from)
            try await removeAcceptedContact(uid: request.from, contactID: request.to)
        default:
            break
        }
    }
    
    func addAcceptedContact(uid: String, contactID: String) async throws {
        var acceptedContactIDs = try await getAcceptedContactIDs(uid: uid)
        acceptedContactIDs.append(contactID)
        try await saveAcceptedContactIDs(uid: uid, contactIDs: acceptedContactIDs)
    }
    
    func removeAcceptedContact(uid: String, contactID: String) async throws {
        var acceptedContactIDs = try await getAcceptedContactIDs(uid: uid)
        acceptedContactIDs.removeAll { $0 == contactID }
        try await saveAcceptedContactIDs(uid: uid, contactIDs: acceptedContactIDs)
    }
    
    private func getAcceptedContactIDs(uid: String) async throws -> [String] {
        let document = try await db.collection("ContactRelations").document(uid).getDocument()
        let data = document.data()
        return data?["acceptedContactIDs"] as? [String] ?? []
    }
    
    private func saveAcceptedContactIDs(uid: String, contactIDs: [String]) async throws {
        try await db.collection("ContactRelations").document(uid).setData(["acceptedContactIDs": contactIDs])
    }
    private func saveblockContactIDs(uid: String, contactIDs: [String]) async throws {
        try await db.collection("ContactRelations").document(uid).setData(["blockedContactIDs": contactIDs])
    }
    
    func blockContact(to: String) async throws {
        let requestID1 = "\(uid)_\(to)"
        let requestID2 = "\(to)_\(uid)"
        
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
        
        try await document.updateData(["status": RequestStatus.blocked.rawValue])
        
        try await removeAcceptedContact(uid: to, contactID: uid)
        try await removeAcceptedContact(uid: uid, contactID: to)
        
        try await saveblockContactIDs(uid: uid, contactIDs: [to])
    }
    
    
}
