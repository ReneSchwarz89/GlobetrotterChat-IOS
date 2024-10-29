//
//  ChatViewModel.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 15.10.24.
//

import SwiftUI
import Foundation
import Observation

@Observable class MessageViewModel {
    var messages: [Message] = []
    var newMessageText: String = ""
    private var manager: MessagesManagerProtocol
    
    init(manager: MessagesManagerProtocol = FirebaseMessagesManager(), chatGroupID: String) {
        self.manager = manager
        setupListeners(chatGroupID: chatGroupID)
    }
    
    func setupListeners(chatGroupID: String) {
        manager.setMessagesListener(chatGroupID: chatGroupID) { [weak self] messages in
            self?.messages = messages
        }
    }
    
    func sendMessage(chatGroupID: String, senderId: String) {
        let message = Message(chatGroupID: chatGroupID, senderId: senderId, text: newMessageText)
        Task {
            do {
                try await manager.sendMessage(message)
                newMessageText = "" // Eingabefeld leeren
            } catch {
                print("Failed to send message: \(error)")
            }
        }
    }
    
    deinit {
        manager.removeListeners()
    }
}
