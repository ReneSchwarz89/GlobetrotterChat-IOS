//
//  Conversation.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 14.10.24.
//

import Foundation
import FirebaseFirestore

struct ChatGroup: Identifiable ,Codable {
    var id: String
    var participants: [String]
    var isGroup: Bool
    var admin: String?
    var latestMessage: Message? 
    @ServerTimestamp var createdAt: Timestamp?
    var isActive: Bool
    var groupName: String?
    var groupPictureURL: String?
    
    init(id: String, participants: [String], isGroup: Bool, admin: String? = nil, latestMessage: Message? = nil, isActive: Bool = true, groupName: String? , groupPictureURL: String?) {
        self.id = id
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
            id: "group1",
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
