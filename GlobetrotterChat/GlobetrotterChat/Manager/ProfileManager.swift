//
//  ProfileManager.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 19.09.24.
//

import Foundation

protocol ProfileManager {
    var profile: Profile? { get set }
    
    func loadProfile() async throws
    func saveProfile(_ profile: Profile) async throws
}
