//
//  ChatViewModel.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 15.10.24.
//

import SwiftUI
import Foundation
import Observation

@Observable class ChatViewModel {
    var messages: [Message] = []
    var newMessageText: String = ""
    var targetLang: String = ""
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
        Task {
            do {
                
                let translationResponse = try await translateText()
                let translatedText = translationResponse.translations.first?.text ?? newMessageText
                
                
                let message = Message(
                    chatGroupID: chatGroupID,
                    senderId: senderId,
                    text: newMessageText,
                    translatedText: translatedText
                )
                
                try await manager.sendMessage(message)
                newMessageText = ""
            } catch {
                print("Failed to send message: \(error)")
            }
        }
    }
    
    private func translateText() async throws -> TranslationResponse {
        return try await DeepLTranslationManager.shared.translateText(text: newMessageText, targetLang: "EN")
    }
    
    deinit {
        manager.removeListeners()
    }
}
