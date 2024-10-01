
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
    private let uid: String
    
    init(uid: String) {
        self.uid = uid
    }
    
    func updateRequestStatus(request: ContactRequest, to newStatus: RequestStatus) async throws {
        let requestID1 = "\(request.from)_\(request.to)"
        let requestID2 = "\(request.to)_\(request.from)"
        
        // Versuche, das Dokument mit der ersten ID zu finden
        var document = db.collection("ContactRequests").document(requestID1)
        var docSnapshot = try await document.getDocument()
        
        if !docSnapshot.exists {
            // Falls das Dokument nicht existiert, versuche es mit der zweiten ID
            document = db.collection("ContactRequests").document(requestID2)
            docSnapshot = try await document.getDocument()
            
            if !docSnapshot.exists {
                print("Request not found")
                return
            }
        }
        
        // Aktualisiere den Status der Anfrage
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
        let document = try await db.collection("Contacts").document(contactID).getDocument()
        if let contact = try document.data(as: Contact?.self) {
            try await db.collection("Contacts").document(uid).collection("AcceptedContacts").document(contactID).setData(contact.toDictionary())
        }
    }
    
    func removeAcceptedContact(uid: String, contactID: String) async throws {
            try await db.collection("Contacts").document(uid).collection("AcceptedContacts").document(contactID).delete()
        }
    
    func sendContactRequest(to: String) async throws {
        let requestID = "\(uid)_\(to)"
        let request = ContactRequest(from: uid, to: to, status: .pending)
        try await db.collection("ContactRequests").document(requestID).setData(request.toDictionary())
    }

    func blockContact(to: String) async throws {
        let requestID1 = "\(uid)_\(to)"
        let requestID2 = "\(to)_\(uid)"
        
        // Versuche, das Dokument mit der ersten ID zu finden
        var document = db.collection("ContactRequests").document(requestID1)
        var docSnapshot = try await document.getDocument()
        
        if !docSnapshot.exists {
            // Falls das Dokument nicht existiert, versuche es mit der zweiten ID
            document = db.collection("ContactRequests").document(requestID2)
            docSnapshot = try await document.getDocument()
            
            if !docSnapshot.exists {
                print("Request not found")
                return
            }
        }
        
        // Aktualisiere den Status der Anfrage
        try await document.updateData(["status": RequestStatus.blocked.rawValue])
        
        // Entferne den Kontakt aus den akzeptierten Kontakten
        try await removeAcceptedContact(uid: to, contactID: uid)
        try await removeAcceptedContact(uid: uid, contactID: to)
        
        // Lösche die Anfrage manuell
    }

}
