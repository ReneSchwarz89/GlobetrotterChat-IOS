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
                    print("Fehler beim Abrufen der möglichen Kontakte")
                    completion([])
                    return
                }
                print("Mögliche Kontakte erfolgreich abgerufen")
                var contacts: [Contact] = []
                let group = DispatchGroup()
                
                // Lade den eigenen Kontakt
                group.enter()
                self.db.collection("Contacts").document(self.uid).getDocument { document, error in
                    if let document = document, let contact = try? document.data(as: Contact.self) {
                        contacts.append(contact)
                    }
                    group.leave()
                }
                
                // Lade die akzeptierten Kontakte
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

    
    func setChatGroupsListener(completion: @escaping ([ChatGroup]) -> Void) {
        chatGroupsListener = db.collection("ChatGroups")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                var chatGroups: [ChatGroup] = []
                for document in documents {
                    if let chatGroup = try? document.data(as: ChatGroup.self),
                       chatGroup.participants.contains(where: { $0.id == self.uid }) {
                        if chatGroup.isActive {
                            chatGroups.append(chatGroup)
                        }
                    }
                }
                completion(chatGroups)
            }
    }
    
    func removeListeners() {
        possibleContactsListener?.remove()
        chatGroupsListener?.remove()
    }
    
    func createChatGroup(chatGroup: ChatGroup) async throws -> Bool {
        let groupID: String
        if chatGroup.isGroup {
            groupID = UUID().uuidString // Generate a new UUID for the group chat
            var updatedChatGroup = chatGroup
            updatedChatGroup.id = groupID // Set the same ID in the ChatGroup model
            try db.collection("ChatGroups").document(groupID).setData(from: updatedChatGroup)
        } else {
            let participants = chatGroup.participants.sorted { $0.id < $1.id } // Sort participants by ID
            groupID = "\(participants[0].id)_\(participants[1].id)" // Use sorted IDs to form the groupID
            
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
        let chatGroupsRef = db.collection("ChatGroups")
        let snapshot = try await chatGroupsRef.getDocuments()
        
        for document in snapshot.documents {
            let chatGroupID = document.documentID
            let chatGroupRef = db.collection("ChatGroups").document(chatGroupID)
            if let chatGroup = try? document.data(as: ChatGroup.self) {
                if chatGroup.participants.contains(where: { $0.id == contactID }) && chatGroup.participants.contains(where: { $0.id == currentUserID }) {
                    if !chatGroup.isGroup {  // Nur aktualisieren, wenn es kein Gruppenchats ist
                        print("Updating isActive to \(isActive) for chatGroupID: \(chatGroupID)")
                        try await chatGroupRef.updateData(["isActive": isActive])
                    }
                }
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
