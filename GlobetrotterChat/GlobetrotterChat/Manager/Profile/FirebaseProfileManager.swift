//
//  FirebaseProfileManager.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 19.09.24.
//

import Foundation
import FirebaseFirestore
import Observation

class FirebaseProfileManager: ProfileManagerProtocol {
    
    var contact: Contact?
    private let uid: String
    
    init(uid: String) {
        self.uid = uid
    }
    
    func loadContact() async throws {
        let document = try await Firestore.firestore().collection("Contacts").document(uid).getDocument()
        let contact = try document.data(as: Contact.self)
        self.contact = contact
    }
    
    func saveContact(_ contact: Contact) async throws {
        if try await profileExists() {
            try await updateContact(contact)
        } else {
            try await createContact(contact)
        }
    }
    
    private func createContact(_ contact: Contact) async throws {
        try Firestore.firestore().collection("Contacts").document(uid).setData(from: contact)
        try await loadContact()
    }
    private func updateContact(_ contact: Contact) async throws {
        try Firestore.firestore().collection("Contacts").document(uid).setData(from: contact, merge: true)
        try await loadContact()
    }
    private func profileExists() async throws -> Bool {
        let document = try await Firestore.firestore().collection("Contacts").document(uid).getDocument()
        return document.exists
    }
}
