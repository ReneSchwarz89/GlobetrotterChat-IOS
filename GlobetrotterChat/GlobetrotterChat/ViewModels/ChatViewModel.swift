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
    var possibleContacts: [Contact] = []
    var newMessageText: String = ""
    
    var uid: String { return manager.uid }
    private var manager: MessagesManagerProtocol
    private var chatGroup: ChatGroup
    
    init(manager: MessagesManagerProtocol = FirebaseMessagesManager(), chatGroup: ChatGroup) {
        self.manager = manager
        self.chatGroup = chatGroup
    }
    
    func setupListeners() {
        let chatGroupID = chatGroup.id
        manager.setMessagesListener(chatGroupID: chatGroupID) { [weak self] messages in
            self?.messages = messages
        }
        FirebaseChatGroupsManager.shared.setPossibleContactsListener { [weak self] contacts in
            self?.possibleContacts = contacts
        }
    }
    
    func sendMessage(chatGroup: ChatGroup) {
        Task {
            do {
                // Hole alle Zielsprachen außer der eigenen
                let targetLangs = chatGroup.participants
                    .filter { $0.id != uid }
                    .map { $0.targetLanguageCode }

                // Übersetze den Text in alle Zielsprachen
                let translationResponses = try await translateText(targetLangs: targetLangs)

                // Erstelle ein Dictionary der Übersetzungen
                var translationsDict: [String: String] = [:]
                for (index, translationResponse) in translationResponses.enumerated() {
                    let targetLang = targetLangs[index]
                    let translatedText = translationResponse.translations.first?.text ?? newMessageText
                    translationsDict[targetLang] = translatedText
                }

                // Erstelle die Nachricht mit den gesammelten Übersetzungen
                let message = Message(
                    id: UUID().uuidString,
                    chatGroupID: chatGroup.id,
                    senderId: uid,
                    text: newMessageText,
                    translations: translationsDict
                )

                try await manager.sendMessage(message)
                newMessageText = ""
            } catch {
                print("Failed to send message: \(error)")
            }
        }
    }

    private func translateText(targetLangs: [String]) async throws -> [TranslationResponse] {
        return try await DeepLTranslationManager.shared.translateText(text: newMessageText, targetLangs: targetLangs)
    }
    
    deinit {
        manager.removeListeners()
        FirebaseChatGroupsManager().removeListeners()
    }
}
