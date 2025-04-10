//
//  ProfileViewModel.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 08.09.24.
//

import SwiftUI
import Observation

@Observable class ProfileViewModel {
    
    var nickname: String = ""
    var nativeLanguage: String = ""
    var profileImage: String?
    var profileImageData: Data?
    var errorMessage: String?
    var isImagePickerPresented: Bool = false
    var isPresentingError = false
    var selectedImage: UIImage?
    
    var contact: Contact?
    var uid: String { return manager.uid }
    
    private var manager: ProfileManagerProtocol
    
    init(manager: ProfileManagerProtocol = FirebaseProfileManager()) {
        self.manager = manager
    }
    
    func loadProfile() {
        Task {
            do {
                try await manager.loadContact()
                self.contact = self.manager.contact
                self.nickname = self.contact?.nickname ?? ""
                self.nativeLanguage = self.contact?.nativeLanguage ?? ""
                self.profileImage = self.contact?.profileImage ?? ""
                
                if let profileImage = self.profileImage {
                   downloadProfileImage(path: profileImage)
                }
            } catch {
                print("Error loading profile: \(error)")
            }
        }
    }
    
    func saveProfile() {
        Task {
            do {
                let contact = Contact(contactID: self.uid, nickname: self.nickname, nativeLanguage: self.nativeLanguage, profileImage: self.profileImage)
                try await manager.saveContact(contact)
                self.contact = contact
                loadProfile()
            } catch {
                print("Error saving profile: \(error)")
               
            }
        }
    }
    
    //Image Workflow
    
    func uploadProfileImage(_ imageData: Data) {
        Task {
            do {
                let path = "profile_images/\(UUID().uuidString).jpg"
                let url = try await FirebaseStorageManager.shared.uploadImage(imageData, path: path)
                self.profileImage = url.absoluteString
                saveProfile()
            } catch {
                self.errorMessage = "Error uploading image: \(error.localizedDescription)"
            }
        }
    }
    
    func downloadProfileImage(path: String) {
        Task {
            do {
                let imageData = try await FirebaseStorageManager.shared.downloadImage(path: path)
                self.profileImageData = imageData
            } catch {
                self.errorMessage = "Error downloading image: \(error.localizedDescription)"
            }
        }
    }
}
