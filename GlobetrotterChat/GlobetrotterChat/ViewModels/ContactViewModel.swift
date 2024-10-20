//
//  ContactViewModel.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 13.09.24.
//

import Foundation
import Observation

@Observable class ContactViewModel {
    var pendingRequests: [ContactRequest] = [] {
        didSet {
            self.newRequestCount = self.pendingRequests.count
            self.showPendingRequestSheet = self.newRequestCount > 0
        }
    }
    var acceptedContacts: [Contact] = []
    var blockedContacts: [Contact] = []
    var newRequestCount: Int = 0

    var showPendingRequestSheet = false
    var alertMessage: String?
    var sendToken: String = ""
    var errorMessage: String?
    private var manager: ContactManagerProtocol
    
    init(manager: ContactManagerProtocol) {
        self.manager = manager
        setupListeners()
    }
    
    func setupListeners() {
        manager.setPendingRequestsListener { [weak self] requests in
            self?.pendingRequests = requests.filter { $0.status == .pending}
            self?.showAlertForNewRequests()
        }
        
        manager.setAcceptedContactsListener { [weak self] contacts in
            self?.acceptedContacts = contacts
        }
        manager.setBlockedContactsListener { [weak self] contacts in
            self?.blockedContacts = contacts
        }
    }
    
    func sendContactRequest() {
        Task {
            do {
                try await manager.sendContactRequest(to: sendToken)
                print("Request sent successfully")
            } catch {
                self.errorMessage = "Error sending request: \(error.localizedDescription)"
                print(self.errorMessage ?? "")
            }
        }
    }
    
    func updateRequestStatus(request: ContactRequest, to newStatus: RequestStatus) {
        Task {
            do {
                try await manager.updateRequestStatus(request: request, to: newStatus)
                print("Request status updated successfully to \(newStatus.rawValue) for request \(request.id)")
                setupListeners()
            } catch {
                self.errorMessage = "Error updating request status: \(error.localizedDescription)"
                print(self.errorMessage ?? "")
            }
        }
    }
    
    func showAlertForNewRequests() {
        if let request = pendingRequests.first(where: { $0.status == .pending }) {
            self.alertMessage = "Do you want to accept the request from \(request.from)?"
            self.showPendingRequestSheet = true
        }
    }
    
    deinit {
        manager.removeListeners()
    }
}
