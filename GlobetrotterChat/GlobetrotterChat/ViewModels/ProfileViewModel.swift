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
    var profileImageURL: String?
    private var lastErrorMessage = ""
    
    private var manager: ProfileManager
    
    init(manager: ProfileManager) {
        self.manager = manager
    }
    
    func createProfile() {
        Task {
            do {
                let profile = Profile(nickname: nickname, nativeLanguage: nativeLanguage)
                try await manager.createProfile(profile)
                nickname = profile.self.nickname
                nativeLanguage = profile.self.nativeLanguage
            } catch {
                lastErrorMessage = error.localizedDescription
                print(lastErrorMessage)
            }
        }
    }
    
    func loadProfile() {
        Task {
            do {
                try await manager.loadProfile()
            } catch {
                lastErrorMessage = error.localizedDescription
                print(lastErrorMessage)
            }
        }
    }
    
    func updateProfile() async throws{
        Task {
            do {
                let newProfile = Profile(nickname: nickname, nativeLanguage: nativeLanguage)
                try await manager.updateProfile(newProfile)
            } catch {
                lastErrorMessage = error.localizedDescription
                print(lastErrorMessage)
            }
        }
    }
}
