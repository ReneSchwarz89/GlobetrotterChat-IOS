//
//  ContactRelations.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 10.10.24.
//

import Foundation

struct ContactRelations: Codable {
    var acceptedContactIDs: [String] = []
    var blockedContactIDs: [String] = []
    
    func toDictionary() -> [String: Any] {
        return  [
            "acceptedContactIDs": acceptedContactIDs,
            "blockedContactIDs": blockedContactIDs
        ]
    }
}
