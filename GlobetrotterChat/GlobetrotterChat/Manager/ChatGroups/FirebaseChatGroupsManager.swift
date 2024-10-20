//
//  FirebaseChatsManager.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 14.10.24.
//

import Foundation
import FirebaseFirestore

@Observable class FirebaseChatGroupsManager: ChatGroupsManagerProtocol {
    static var shared: FirebaseChatGroupsManager = FirebaseChatGroupsManager()
    
    private var db = Firestore.firestore()
    private let uid: String
    private var possibleContactsListener: ListenerRegistration?
    
    init(uid: String = AuthServiceManager.shared.userID ?? "") {
        self.uid = uid
    }
    
    func setPossibleContactsListener(completion: @escaping ([Contact]) -> Void) {
        possibleContactsListener = db.collection("Contacts").document(uid).collection("ContactRelations")
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
    
    func removeListeners() {
        possibleContactsListener?.remove()
    }
    
    func createChatGroup(_ chatGroup: ChatGroup) async throws {
        try db.collection("ChatGroups").addDocument(from: chatGroup)
    }
    
}




/*
 static let shared = FirebaseChatGroupsManager()
 
 private var db = Firestore.firestore()
 private let uid: String
 private var chatGroupsListener: ListenerRegistration?
 private var contactsListener: ListenerRegistration?
     
 var acceptedContacts: [Contact] = []
 var chatGroups: [ChatGroup] = []
 
 private init() {
     self.uid = AuthServiceManager.shared.userID ?? ""// Beispiel für die UID des aktuellen Nutzers
     loadChatGroups()
     
 }
 
 
 
 func addParticipant(chatGroupId: String, participantId: String) async throws {
     let chatGroupRef = db.collection("ChatGroups").document(chatGroupId)
     try await chatGroupRef.updateData([
         "participants": FieldValue.arrayUnion([participantId])
     ])
 }
 
 func removeParticipant(chatGroupId: String, participantId: String) async throws {
     let chatGroupRef = db.collection("ChatGroups").document(chatGroupId)
     try await chatGroupRef.updateData([
         "participants": FieldValue.arrayRemove([participantId])
     ])
 }
 
 */
