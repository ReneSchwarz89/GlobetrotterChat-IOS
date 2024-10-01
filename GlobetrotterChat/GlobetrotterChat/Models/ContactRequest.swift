//
//  File.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 24.09.24.
//

import Foundation

struct ContactRequest: Codable {
    var from: String
    var to: String
    var status: RequestStatus = .pending
    
    var id: String {
           return "\(from)_\(to)"
       }
    
    func toDictionary() -> [String: Any] {
        return [
            "from": from,
            "to": to,
            "status": status.rawValue
        ]
    }
}

enum RequestStatus: String, Codable {
    case pending
    case allowed
    case blocked
}
