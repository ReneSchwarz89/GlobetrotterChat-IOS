//
//  FirebaseMessagesManager.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 14.10.24.
//

import Foundation
import FirebaseFirestore

@Observable class FirebaseMessagesManager: MessagesManagerProtocol {
    private var db = Firestore.firestore()
    private var messagesListener: ListenerRegistration?
    
    func sendMessage(_ message: Message) async throws {
        let chatGroupMessagesRef = db.collection("ChatGroups").document(message.chatGroupID).collection("Messages").document()
        try await chatGroupMessagesRef.setData(message.toDictionary())
    }
    
    func setMessagesListener(chatGroupID: String, completion: @escaping ([Message]) -> Void) {
        messagesListener = db.collection("ChatGroups").document(chatGroupID).collection("Messages") // Sammlung "Messages" anstatt `chatGroupID`
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                let messages = documents.compactMap { try? $0.data(as: Message.self) }
                completion(messages)
            }
    }
    
    func removeListeners() {
        messagesListener?.remove()
    }
}
