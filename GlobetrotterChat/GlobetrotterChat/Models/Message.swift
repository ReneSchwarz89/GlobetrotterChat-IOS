//
//  Message.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 14.10.24.
//

import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var chatGroupID: String
    var senderId: String
    var text: String
    var translations: [String:String]
    @ServerTimestamp var timestamp: Timestamp?

    func toDictionary() -> [String: Any] {
        return [
            "chatGroupID": chatGroupID,
            "senderId": senderId,
            "text": text,
            "translations": translations,
            "timestamp": timestamp ?? Timestamp()
        ]
    }

    static let sample = Message(
        chatGroupID: "1",
        senderId: "user2",
        text: "Hello",
        translations: ["Hallo":"DE"]
    )
}

