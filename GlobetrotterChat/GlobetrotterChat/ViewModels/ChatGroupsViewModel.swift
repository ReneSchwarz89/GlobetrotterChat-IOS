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
    private var currentUserID: String
    
    init(manager: ChatGroupsManagerProtocol = FirebaseChatGroupsManager(), currentUserID: String = AuthServiceManager.shared.userID ?? "") {
        self.manager = manager
        self.currentUserID = currentUserID
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
                print("Image uploaded successfully: \(url)")
            } catch {
                print("Error uploading image: \(error.localizedDescription)")
            }
        }
    }
    
    func createChatGroup() {
        // Holen der `nativeLanguage` für jeden `selectedContact`
        let participants = Array(Set(selectedContacts)).map { contactID -> Participant in
            // Finde den Kontakt im `possibleContacts`-Array, um die `nativeLanguage` zu bekommen
            let contact = possibleContacts.first { $0.contactID == contactID }
            return Participant(id: contactID, targetLanguageCode: contact?.nativeLanguage ?? "EN") // Default auf "EN", falls kein Kontakt gefunden wird
        }
        
        let isGroup = participants.count > 1
        let adminID = isGroup ? (AuthServiceManager.shared.user?.uid ?? "") : nil
        let chatGroupID: String
        
        if isGroup {
            chatGroupID = UUID().uuidString
        } else if let contactID1 = participants.first?.id, let contactID2 = participants.last?.id {
            let sortedIDs = [contactID1, contactID2].sorted()
            chatGroupID = sortedIDs.joined(separator: "_")
        } else {
            return
        }
        
        // Holen der `nativeLanguage` des aktuellen Nutzers aus den `possibleContacts`
        let userID = AuthServiceManager.shared.userID ?? ""
        let userNativeLanguage = possibleContacts.first { $0.contactID == userID }?.nativeLanguage ?? "EN"
        
        let newChatGroup = ChatGroup(
            id: chatGroupID,
            participants: [Participant(id: userID, targetLanguageCode: userNativeLanguage)] + participants,
            isGroup: isGroup,
            admin: adminID,
            groupName: isGroup ? groupName : nil,
            groupPictureURL: isGroup ? groupPictureURL : nil
        )
        
        Task {
            do {
                let created = try await manager.createChatGroup(chatGroup: newChatGroup)
                if created {
                    isAddChatGroupSheetPresented = false
                } else {
                    alertMessage = "Group already exists."
                    showAlert = true
                }
            } catch {
                print("Error creating chat group: \(error)")
            }
        }
    }


    func getUserNativeLanguage() -> String {
        // Implementiere hier die Logik, um die nativeLanguage des aktuellen Nutzers zu erhalten
        // Beispielweise:
        return possibleContacts.first { $0.contactID == AuthServiceManager.shared.userID }?.nativeLanguage ?? "EN"
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

