//
//  ContactManagerProtocol.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 26.09.24.
//

import Foundation

protocol ContactManagerProtocol {
    var uid: String { get }
    
    func setPendingRequestsListener(completion: @escaping ([ContactRequest]) -> Void)
    func setAcceptedContactsListener(completion: @escaping ([Contact]) -> Void)
    func setBlockedContactsListener(completion: @escaping ([Contact]) -> Void)
    func sendContactRequest(to: String) async throws
    func updateRequestStatus(request: ContactRequest, to newStatus: RequestStatus) async throws
    func removeListeners()
}
