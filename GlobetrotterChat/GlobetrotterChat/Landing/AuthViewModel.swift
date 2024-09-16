//
//  AuthViewModel.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 13.09.24.
//

import SwiftUI
import Observation

@Observable class AuthViewModel {
    var email: String = ""
    var password: String = ""
    var authState: AuthState = .neutral

    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository = AuthRepositoryImpl()) {
        self.authRepository = authRepository
        checkAuthState()
    }
    
    func signIn(email: String, password: String) {
        Task {
            do {
                try await authRepository.signIn(email: email, password: password)
                authState = .loggedIn
            } catch {
                // Handle error
            }
        }
    }

    func signUp(email: String, password: String) {
        Task {
            do {
                try await authRepository.signUp(email: email, password: password)
                authState = .signedUpAndLoggedIn
            } catch {
                // Handle error
            }
        }
    }

    func signOut() {
        do {
            try authRepository.signOut()
            authState = .neutral
        } catch {
            // Handle error
        }
    }
    
    private func checkAuthState() {
        if authRepository.isUserSignedIn {
            authState = .loggedIn
        } else {
            authState = .neutral
        }
    }
}
