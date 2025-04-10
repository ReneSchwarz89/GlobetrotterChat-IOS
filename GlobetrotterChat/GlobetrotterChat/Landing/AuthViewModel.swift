//
//  AuthViewModel.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 13.09.24.
//

import SwiftUI
import Observation

enum AuthError: LocalizedError {
    case noEmail
    case notAuthenticated
    case emailAlreadyInUse
    case weakPassword
    case invalidEmail
    case invalidLogout
    
    var errorDescription: String? {
        switch self {
        case .noEmail:
            return "Bitte E-Mail-Adresse eingeben."
        case .notAuthenticated:
            return "The user is not authenticated."
        case .emailAlreadyInUse:
            return "The email address is already in use."
        case .weakPassword:
            return "The password must be at least 6 characters long."
        case .invalidEmail:
            return "The email address is invalid."
        case .invalidLogout:
            return "Logout failed. Check your internet connection."
        }
    }
}

@Observable class AuthViewModel {
    var email: String = ""
    var password: String = ""
    var error: AuthError?
    var isPasswordVisible: Bool = false
    var hasPressedSignUp = false
    var hasPressedSignIn = false
    var lastErrorMessage = ""
    var isPresentingError = false
    
    func signIn(email: String, password: String) {
        Task {
            guard !email.isEmpty else {
                error = AuthError.noEmail
                return
            }
            guard password.count >= 6 else {
                error = AuthError.weakPassword
                return
            }
            do {
                try await AuthServiceManager.shared.signIn(email: email, password: password)
                clearPrivateInfo()
            } catch let error as AuthError {
                self.error = error
                isPresentingError = true
            } catch {
                self.error = AuthError.notAuthenticated
                isPresentingError = true
            }
        }
    }
    
    func signUp(email: String, password: String) {
        Task {
            guard isValidEmail(email) else {
                error = AuthError.invalidEmail
                return
            }
            guard password.count >= 6 else {
                error = AuthError.weakPassword
                return
            }
            do {
                try await AuthServiceManager.shared.signUp(email: email, password: password)
                clearPrivateInfo()
            } catch let error as AuthError {
                self.error = error
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailPred.evaluate(with: email)
    }
    
    private func clearPrivateInfo() {
        Task {@MainActor in
            try await Task.sleep(nanoseconds: 2 * 2_000_000_000) // 2 Sekunden Delay
                email = ""
                password = ""
        }
    }
}
