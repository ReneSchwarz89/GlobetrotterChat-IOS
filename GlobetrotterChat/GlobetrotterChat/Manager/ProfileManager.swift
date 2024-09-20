//
//  ProfileManager.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 19.09.24.
//

import Foundation

protocol ProfileManager {
    var profile: Profile? { get set }
    
    func createProfile(_ profile: Profile) async throws
    func loadProfile() async throws
    func updateProfile(_ profile: Profile) async throws
}
