//
//  ProfileManager.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 19.09.24.
//

import Foundation

protocol ContactManager {
    var contact: Contact? { get set }
    
    func loadContact() async throws
    func saveContact(_ contact: Contact) async throws
}
