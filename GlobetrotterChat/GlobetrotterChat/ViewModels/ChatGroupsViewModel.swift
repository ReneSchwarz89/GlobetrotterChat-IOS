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
    var chatGroups: [ChatGroup] = []
    var isAddChatGroupSheetPresented = false
    var isGroup = false
    var groupName: String = ""
    var groupPictureURL: String = ""
    var imageData: Data?
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
        manager.setChatGroupsListener {[weak self] chatGroups in
            self?.chatGroups = chatGroups
        }
    }
    
    func toggleContactSelection(contactID: String) {
        if selectedContacts.contains(contactID) {
            selectedContacts.remove(contactID)
        } else {
            selectedContacts.insert(contactID)
        }
    }
    
    func uploadGroupImage(_ imageData: Data) {
        Task {
            do {
                let path = "chat-groups/\(UUID().uuidString)"
                let url = try await FirebaseStorageManager.shared.uploadImage(imageData, path: path)
                self.groupPictureURL = url.absoluteString
                print("Image uploaded successfully: \(url)")
            } catch {
                print("Error uploading image: \(error.localizedDescription)")
            }
        }
    }
    func createChatGroup() {
        let participants = Array(selectedContacts)
        let isGroup = participants.count > 1
        let adminID = AuthServiceManager.shared.user?.uid ?? ""
        
        let newChatGroup = ChatGroup(
            participants: [adminID] + participants,
            isGroup: isGroup,
            admin: adminID,
            groupName: isGroup ? groupName : nil,
            groupPictureURL: isGroup ? groupPictureURL : nil
        )
        
        Task {
            do {
                try await manager.createChatGroup(chatGroup: newChatGroup)
                isAddChatGroupSheetPresented = false
            } catch {
                print("Error creating chat group: \(error)")
            }
        }
    }
    func resetSelections() {
        selectedContacts.removeAll()
        groupName = ""
        groupPictureURL = ""
        imageData = nil
    }
    deinit {
        manager.removeListeners()
    }
}

