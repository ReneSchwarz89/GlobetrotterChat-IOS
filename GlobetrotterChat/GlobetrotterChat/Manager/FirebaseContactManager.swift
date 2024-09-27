
//
//  FirebaseContactManager.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 26.09.24.
//
import SwiftUI
import FirebaseFirestore

class FirebaseContactManager: ContactManagerProtocol {
    
    private var db = Firestore.firestore()
    
    func updateRequestStatus(request: ContactRequest, to newStatus: RequestStatus) async throws {
        let query = db.collection("ContactRequests")
            .whereField("from", isEqualTo: request.from)
            .whereField("to", isEqualTo: request.to)
            .whereField("status", isEqualTo: RequestStatus.pending.rawValue)
        
        let snapshot = try await query.getDocuments()
        guard let document = snapshot.documents.first else { return }
        
        try await document.reference.updateData(["status": newStatus.rawValue])
        
        if newStatus == .allowed {
            try await addAcceptedContact(uid: request.to, contactID: request.from)
            try await addAcceptedContact(uid: request.from, contactID: request.to)
        }
    }
    
    func addAcceptedContact(uid: String, contactID: String) async throws {
        let document = try await db.collection("Contacts").document(contactID).getDocument()
        if let contact = try document.data(as: Contact?.self) {
            try await db.collection("Contacts").document(uid).collection("AcceptedContacts").document(contactID).setData(contact.toDictionary())
        }
    }
    
    func sendContactRequest(from: String, to: String) async throws {
        let request = ContactRequest(from: from, to: to, status: .pending)
        try await db.collection("ContactRequests").addDocument(data: request.toDictionary())
    }
}
