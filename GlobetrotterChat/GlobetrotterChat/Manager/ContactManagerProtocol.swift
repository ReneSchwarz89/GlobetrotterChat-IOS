//
//  ContactManagerProtocol.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 26.09.24.
//

import Foundation

protocol ContactManagerProtocol {
    func updateRequestStatus(request: ContactRequest, to newStatus: RequestStatus) async throws
    func addAcceptedContact(uid: String, contactID: String) async throws 
    func sendContactRequest(to: String) async throws
    func blockContact(to: String) async throws
}
