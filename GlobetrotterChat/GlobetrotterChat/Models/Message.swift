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
    var chatGroupID: String
    var senderId: String
    var text: String
    var timestamp: Timestamp
    
    init(id: String? = nil, chatGroupID: String, senderId: String, text: String, timestamp: Timestamp) {
        self.id = id
        self.chatGroupID = chatGroupID
        self.senderId = senderId
        self.text = text
        self.timestamp = timestamp
    }
    
    static let sample = Message(
        chatGroupID: "1",
        senderId: "user2",
        text: "Hello",
        timestamp: Timestamp()
    )
}
