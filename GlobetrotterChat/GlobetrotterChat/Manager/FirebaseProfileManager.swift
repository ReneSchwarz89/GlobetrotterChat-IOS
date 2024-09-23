//
//  FIrebaseProfileManager.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 19.09.24.
//

import Foundation
import FirebaseFirestore
import Observation

class FirebaseProfileManager: ProfileManager {
    
    var profile: Profile?
    private let uid: String
    
    init(uid: String) {
        self.uid = uid
    }
    
    private func createProfile(_ profile: Profile) async throws {
        try Firestore.firestore().collection("Profiles").document(uid).setData(from: profile)
        try await loadProfile()
    }
    
    func loadProfile() async throws {
        let document = try await Firestore.firestore().collection("Profiles").document(uid).getDocument()
        let profile = try document.data(as: Profile.self)
        self.profile = profile
    }
    
    private func updateProfile(_ profile: Profile) async throws {
        try Firestore.firestore().collection("Profiles").document(uid).setData(from: profile, merge: true)
        try await loadProfile()
    }
    
    func saveProfile(_ profile: Profile) async throws {
        if try await profileExists() {
            try await updateProfile(profile)
        } else {
            try await createProfile(profile)
        }
    }
    
    private func profileExists() async throws -> Bool {
        let document = try await Firestore.firestore().collection("Profiles").document(uid).getDocument()
        return document.exists
    }
}
