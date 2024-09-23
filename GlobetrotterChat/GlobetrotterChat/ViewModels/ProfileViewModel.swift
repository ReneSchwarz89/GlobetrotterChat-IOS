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
    
    private var manager: ProfileManager
    var profile: Profile?
    
    init(manager: ProfileManager) {
        self.manager = manager
        self.loadProfile()
        
    }
    
    func loadProfile() {
        Task {
            do {
                try await manager.loadProfile()
                DispatchQueue.main.async {
                    self.profile = self.manager.profile
                    self.nickname = self.profile?.nickname ?? ""
                    self.nativeLanguage = self.profile?.nativeLanguage ?? ""
                    print("Profile loaded: \(String(describing: self.profile))")
                }
            } catch {
                print("Error loading profile: \(error)")
            }
        }
    }
    
    func saveProfile() {
            Task {
                do {
                    let profile = Profile(nickname: self.nickname, nativeLanguage: self.nativeLanguage, profileImage: self.profileImage)
                    try await manager.saveProfile(profile)
                    DispatchQueue.main.async {
                        self.profile = profile
                        print("Profile saved: \(profile)")
                    }
                } catch {
                    print("Error saving profile: \(error)")
                }
            }
        }
}
