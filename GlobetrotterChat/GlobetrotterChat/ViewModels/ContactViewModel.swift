//
//  ContactViewModel.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 13.09.24.
//

import FirebaseFirestore

@Observable class ContactViewModel {
    var pendingRequests: [ContactRequest] = [] {
        didSet {
            // Aktualisiere die Anzeige, wenn sich die Anzahl der neuen Anfragen ändert
            self.newRequestCount = self.pendingRequests.count
            self.showSheet = self.newRequestCount > 0
        }
    }
    var acceptedContacts: [Contact] = []
    var newRequestCount: Int = 0
    
    var showSheet = false
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
            self?.pendingRequests = requests
            self?.showAlertForNewRequests()
        }
        
        manager.setAcceptedContactsListener { [weak self] contacts in
            self?.acceptedContacts = contacts
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
                print("Request status updated successfully")
                setupListeners()
            } catch {
                self.errorMessage = "Error updating request status: \(error.localizedDescription)"
                print(self.errorMessage ?? "")
            }
        }
    }
    
    func blockContact(contactID: String) {
        Task {
            do {
                try await manager.blockContact(to: contactID)
                print("Contact blocked successfully")
                // Listener neu starten, um die Liste der ausstehenden Anfragen zu aktualisieren
                setupListeners()
            } catch {
                self.errorMessage = "Error blocking contact: \(error.localizedDescription)"
                print(self.errorMessage ?? "")
            }
        }
    }
    
    
    func showAlertForNewRequests() {
        // Logik zum Anzeigen des Alerts für neue Anfragen
        if let request = pendingRequests.first(where: { $0.status == .pending }) {
            self.alertMessage = "Do you want to accept the request from \(request.from)?"
            self.showSheet = true
        }
    }
    
    
    deinit {
        manager.removeListeners()
    }
}
