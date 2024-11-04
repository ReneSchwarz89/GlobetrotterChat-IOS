//
//  Conversation.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 14.10.24.
//

import Foundation
import FirebaseFirestore

struct ChatGroup: Identifiable ,Codable , Hashable {
    var id: String
    var participants: [Participant]
    var isGroup: Bool
    var admin: String?
    var latestMessage: Message? 
    @ServerTimestamp var createdAt: Timestamp?
    var isActive: Bool
    var groupName: String?
    var groupPictureURL: String?
    
    init(id: String, participants: [Participant], isGroup: Bool, admin: String? = nil, latestMessage: Message? = nil, isActive: Bool = true, groupName: String? , groupPictureURL: String?) {
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
            participants: [Participant(id: "user1", targetLanguageCode: "en", nickname: "hans"), Participant(id: "user2", targetLanguageCode: "de",nickname: "peter")],
            isGroup: false,
            admin: "user1",
            latestMessage: Message.sample,
            isActive: true,
            groupName: "Study Group",
            groupPictureURL: "https://example.com/group.jpg"
        )
    }
}

struct Participant: Identifiable, Codable, Hashable {
    var id: String
    var targetLanguageCode: String
    var nickname: String
    
    func toDictionary() -> [String: Any] {
        ["id": id,
         "targetLanguageCode": targetLanguageCode,
         "nickname": nickname
        ]
    }
}
