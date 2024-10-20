//
//  Conversation.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 14.10.24.
//

import Foundation
import FirebaseFirestore

struct ChatGroup: Identifiable, Codable {
    @DocumentID var id: String?
    var participants: [String]
    var isGroup: Bool //
    var admin: String?
    var latestMessage: Message? // Neueste Nachricht
    @ServerTimestamp var createdAt: Timestamp?
    var isActive: Bool
    var groupName: String?
    var groupPictureURL: String?
    
    init(participants: [String], isGroup: Bool, admin: String? = nil, latestMessage: Message? = nil, isActive: Bool = true, groupName: String? = nil, groupPictureURL: String? = nil) {
        self.participants = participants
        self.isGroup = isGroup
        self.admin = admin
        self.latestMessage = latestMessage
        self.isActive = isActive
        self.groupName = groupName
        self.groupPictureURL = groupPictureURL
    }
}

extension ChatGroup {
    static var sample: Self {
        .init(
            participants: ["user1", "user2"],
            isGroup: false,
            admin: "user1",
            latestMessage: Message.sample,
            isActive: true,
            groupName: "Study Group",
            groupPictureURL: "https://example.com/group.jpg"
        )
    }
}


