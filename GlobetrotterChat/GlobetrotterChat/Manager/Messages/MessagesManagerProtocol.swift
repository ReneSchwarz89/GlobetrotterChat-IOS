//
//  MessagesManagerProtocol.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 14.10.24.
//

import Foundation

protocol MessagesManagerProtocol {
    func sendMessage(_ message: Message) async throws
    func setMessagesListener(chatGroupID: String, completion: @escaping ([Message]) -> Void)
    func removeListeners()
}
