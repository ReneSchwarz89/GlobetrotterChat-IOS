//
//  ConversationsViewModel.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 13.09.24.
//

import Foundation
import Observation
import UIKit

@Observable
class ChatGroupsViewModel {
    
    var possibleContacts: [Contact] = []
    var selectedContacts: Set<String> = []
    var isAddChatGroupSheetPresented = false
    var isGroup = false
    var groupName: String = ""
    var groupPictureURL: String = ""
    var selectedImage: UIImage?
    var isUploadingImage = false
    
    private var manager: ChatGroupsManagerProtocol
    
    init(manager: ChatGroupsManagerProtocol = FirebaseChatGroupsManager()) {
        self.manager = manager
        setupListeners()
    }
    
    func setupListeners() {
        manager.setPossibleContactsListener { [weak self] possibleContacts in
            self?.possibleContacts = possibleContacts
        }
    }
    
    func toggleContactSelection(contactID: String) {
        if selectedContacts.contains(contactID) {
            selectedContacts.remove(contactID)
        } else {
            selectedContacts.insert(contactID)
        }
    }
    
    func createChatGroup(participants: [String], isGroup: Bool, groupName: String, groupPictureURL: String) {
        Task {
            do {
                let newChatGroup = ChatGroup(
                    participants: participants,
                    isGroup: isGroup,
                    admin: AuthServiceManager.shared.user?.uid ?? "",
                    groupName: isGroup ? groupName : nil,
                    groupPictureURL: isGroup ? groupPictureURL : nil
                )
                try await manager.createChatGroup(newChatGroup)
            } catch {
                print("Error creating chat group: \(error)")
            }
        }
    }
    
    deinit {
        manager.removeListeners()
    }
}

