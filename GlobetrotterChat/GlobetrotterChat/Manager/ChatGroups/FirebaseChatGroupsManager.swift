//
//  FirebaseChatsManager.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 14.10.24.
//

import Foundation
import FirebaseFirestore
import Observation

@Observable class FirebaseChatGroupsManager: ChatGroupsManagerProtocol {
    static var shared = FirebaseChatGroupsManager()
    
    private var db = Firestore.firestore()
    private let uid: String
    private var possibleContactsListener: ListenerRegistration?
    private var chatGroupsListener: ListenerRegistration?
    
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
    
    // Setzt den Listener für Chat-Gruppen
    func setChatGroupsListener(completion: @escaping ([ChatGroup]) -> Void) {
        chatGroupsListener = db.collection("ChatGroups")
            .whereField("participants", arrayContains: uid)
            .whereField("isActive", isEqualTo: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                let chatGroups: [ChatGroup] = documents.compactMap { document in
                    try? document.data(as: ChatGroup.self)
                }
                completion(chatGroups)
            }
    }

    
    // Entfernt die Listener
    func removeListeners() {
        possibleContactsListener?.remove()
        chatGroupsListener?.remove()
    }
    
    // Erstellt eine neue Chat-Gruppe
    func createChatGroup(chatGroup: ChatGroup) async throws -> Bool {
        let groupID: String
        if chatGroup.isGroup {
            groupID = UUID().uuidString // Generate a new UUID for the group chat
            var updatedChatGroup = chatGroup
            updatedChatGroup.id = groupID // Set the same ID in the ChatGroup model
            try db.collection("ChatGroups").document(groupID).setData(from: updatedChatGroup)
        } else {
            let participants = chatGroup.participants.sorted()
            groupID = "\(participants[0])_\(participants[1])"
            // Check if a single chat already exists
            let existingChatGroup = try await db.collection("ChatGroups")
                .whereField("id", isEqualTo: groupID)
                .getDocuments()
            if existingChatGroup.documents.isEmpty {
                var updatedChatGroup = chatGroup
                updatedChatGroup.id = groupID // Set the same ID in the ChatGroup model
                try db.collection("ChatGroups").document(groupID).setData(from: updatedChatGroup)
                return true // New group created
            } else {
                // Group already exists, update without createdAt
                let chatGroupRef = db.collection("ChatGroups").document(groupID)
                let data = try await chatGroupRef.getDocument()
                if let existingChatGroup = try? data.data(as: ChatGroup.self) {
                    var updatedChatGroup = existingChatGroup
                    updatedChatGroup.createdAt = existingChatGroup.createdAt // Retain the original timestamp
                    try chatGroupRef.setData(from: updatedChatGroup, merge: true)
                    return false // Group already exists
                } else {
                    throw NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve existing chat group."])
                }
            }
        }
        return false
    }
    func updateChatGroupActivity(for currentUserID: String, contactID: String, isActive: Bool) async throws {
            let chatGroupsRef = db.collection("ChatGroups").whereField("participants", arrayContainsAny: [currentUserID, contactID])
            let snapshot = try await chatGroupsRef.getDocuments()
            for document in snapshot.documents {
                let chatGroupID = document.documentID
                let chatGroupRef = db.collection("ChatGroups").document(chatGroupID)
                let chatGroup = try document.data(as: ChatGroup.self)
                if chatGroup.participants.contains(contactID) && chatGroup.participants.contains(currentUserID) && !chatGroup.isGroup {
                    try await chatGroupRef.updateData(["isActive": isActive])
                }
            }
        }
    func doesChatGroupExist(otherContactID: String) async throws -> Bool {
        let participants = [self.uid, otherContactID].sorted()
        let chatGroupID = "\(participants[0])_\(participants[1])"

        let existingChatGroup = try await db.collection("ChatGroups")
            .whereField("id", isEqualTo: chatGroupID)
            .getDocuments()

        return !existingChatGroup.documents.isEmpty
    }

    func addChatGroupReferences(for contactIDs: [String], chatGroupID: String) {
            contactIDs.forEach { contactID in
                let contactRef = db.collection("contacts").document(contactID).collection("contactRelations").document("chatgroups")
                contactRef.updateData(["chatGroupIDs": FieldValue.arrayUnion([chatGroupID])])
            }
        }
}

