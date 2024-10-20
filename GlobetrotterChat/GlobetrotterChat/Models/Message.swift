//
//  Message.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 14.10.24.
//

import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var conversationId: String
    var senderId: String
    var text: String
    var timestamp: Timestamp
    
    init(id: String? = nil, conversationId: String, senderId: String, text: String, timestamp: Timestamp) {
        self.id = id
        self.conversationId = conversationId
        self.senderId = senderId
        self.text = text
        self.timestamp = timestamp
    }
    
    static let sample = Message(
        conversationId: "1",
        senderId: "user2",
        text: "Hello",
        timestamp: Timestamp()
    )
}
