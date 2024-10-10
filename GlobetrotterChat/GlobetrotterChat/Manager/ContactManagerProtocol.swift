//
//  ContactManagerProtocol.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 26.09.24.
//

import Foundation
import FirebaseFirestore

protocol ContactManagerProtocol {
    func sendContactRequest(to: String) async throws
    func updateRequestStatus(request: ContactRequest, to newStatus: RequestStatus) async throws
    func blockContact(to: String) async throws
    func removeListeners()
    func setPendingRequestsListener(completion: @escaping ([ContactRequest]) -> Void)
    func setAcceptedContactsListener(completion: @escaping ([Contact]) -> Void)
}
