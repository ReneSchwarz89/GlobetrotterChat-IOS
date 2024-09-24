//
//  ProfileViewModel.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 08.09.24.
//
import Foundation
import Observation

@Observable class ProfileViewModel {
    
    var nickname: String = ""
    var nativeLanguage: String = ""
    var profileImage: String?
    private var lastErrorMessage = ""
    
    private var manager: ContactManager
    var contact: Contact?
    
    init(manager: ContactManager) {
        self.manager = manager
    }
    
    func loadProfile() {
        Task {
            do {
                try await manager.loadContact()
                
                    self.contact = self.manager.contact
                    self.nickname = self.contact?.nickname ?? ""
                    self.nativeLanguage = self.contact?.nativeLanguage ?? ""
                
            } catch {
                print("Error loading profile: \(error)")
            }
        }
    }
    
    func saveProfile() {
        Task {
            do {
                let contact = Contact(nickname: self.nickname, nativeLanguage: self.nativeLanguage, profileImage: self.profileImage)
                try await manager.saveContact(contact)
                self.contact = contact
            } catch {
                print("Error saving profile: \(error)")
            }
        }
    }
}
