//
//  ChatsManagerProtocol.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 14.10.24.
//

import Foundation

protocol ChatGroupsManagerProtocol {
    var uid: String { get }
    func setPossibleContactsListener(completion: @escaping ([Contact]) -> Void)
    func setChatGroupsListener(completion: @escaping ([ChatGroup]) -> Void)
    func removeListeners()
    func createChatGroup(chatGroup: ChatGroup) async throws -> Bool
    func doesChatGroupExist(otherContactID: String) async throws -> Bool
    
}
/*
 func addParticipant(chatGroupId: String, participantId: String) async throws
 func removeParticipant(chatGroupId: String, participantId: String) async throws
 func loadChatGroups()
 func stopListeners()
 */


