//
//  ChatsManagerProtocol.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 14.10.24.
//

import Foundation

protocol ChatGroupsManagerProtocol {
    func setPossibleContactsListener(completion: @escaping ([Contact]) -> Void)
    func removeListeners()
    func createChatGroup(_ chatGroup: ChatGroup) async throws
}


/*
 
 func createChatGroup(_ chatGroup: ChatGroup) async throws
 func addParticipant(chatGroupId: String, participantId: String) async throws
 func removeParticipant(chatGroupId: String, participantId: String) async throws
 func loadChatGroups()
 func stopListeners()
 */


