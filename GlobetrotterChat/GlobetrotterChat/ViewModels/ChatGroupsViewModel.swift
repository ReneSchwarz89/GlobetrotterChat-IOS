//
//  ConversationsViewModel.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 13.09.24.
//

import Foundation
import Observation
import UIKit

@Observable class ChatGroupsViewModel {
    var possibleContacts: [Contact] = []
    var selectedContacts: Set<String> = []
    var chatGroups: [ChatGroup] = []
    var isAddChatGroupSheetPresented = false
    var isGroup = false
    var groupName: String = ""
    var groupPictureURL: String = ""
    var imageData: Data?
    var isUploadingImage = false
    var showAlert = false
    var alertMessage = ""
    
    private var manager: ChatGroupsManagerProtocol
    var uid: String { return manager.uid }
    
    init(manager: ChatGroupsManagerProtocol = FirebaseChatGroupsManager()) {
        self.manager = manager
        setupListeners()
    }
    
    func setupListeners() {
        manager.setPossibleContactsListener { [weak self] possibleContacts in
            self?.possibleContacts = possibleContacts
            print("Possible contacts updated: \(possibleContacts)") // Debug
        }
        manager.setChatGroupsListener { [weak self] chatGroups in
            self?.chatGroups = chatGroups
            print("Chat groups updated: \(chatGroups)") // Debug
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
            } catch {
                print("Error uploading image: \(error.localizedDescription)")
            }
        }
    }
    
    func checkIfGroup() -> Bool {
        return selectedContacts.count > 1
    }
    
    func createChatGroup() {
        let participants = Array(Set(selectedContacts)).map { contactID -> Participant in
            let contact = possibleContacts.first { $0.contactID == contactID }
            return Participant(id: contactID, targetLanguageCode: contact?.nativeLanguage ?? "EN")
        }
        
        isGroup = checkIfGroup()
        let adminID = isGroup ? (uid) : nil
        let chatGroupID: String
        
        if isGroup {
            chatGroupID = UUID().uuidString
        } else if let contactID1 = participants.first?.id, let contactID2 = participants.last?.id {
            let sortedIDs = [contactID1, contactID2].sorted()
            chatGroupID = sortedIDs.joined(separator: "_")
        } else {
            return
        }
        
        let userNativeLanguage = possibleContacts.first { $0.contactID == uid }?.nativeLanguage ?? "EN"
        
        let newChatGroup = ChatGroup(
            id: chatGroupID,
            participants: [Participant(id: self.uid, targetLanguageCode: userNativeLanguage)] + participants,
            isGroup: isGroup,
            admin: adminID,
            groupName: isGroup ? groupName : nil,
            groupPictureURL: isGroup ? groupPictureURL : nil
        )
        
        Task {
            do {
                let created = try await manager.createChatGroup(chatGroup: newChatGroup)
                if created {
                    resetSelections()
                    isAddChatGroupSheetPresented = false
                } else {
                    // Hier den Namen des Kontakts aus `possibleContacts` holen
                    if let selectedContact = possibleContacts.first(where: { $0.contactID == newChatGroup.participants.last?.id }) {
                        alertMessage = "Chat with \(selectedContact.nickname) already exists."
                    } else {
                        alertMessage = "Chat with this contact already exists."
                    }
                    showAlert = true
                    selectedContacts.removeAll()
                }
            } catch {
                print("Error creating chat group: \(error.localizedDescription)")
                alertMessage = "Error creating chat group: \(error.localizedDescription)"
                showAlert = true
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
