//
//  FirebaseAuthManager.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 08.09.24.
//

import Foundation
import FirebaseAuth

class FirebaseAuthService {
    static let shared = FirebaseAuthService()
    
    private let auth = Auth.auth()
    
    var user: FirebaseAuth.User? { auth.currentUser }
    var isUserSignedIn: Bool { user != nil }
    var userID: String? { user?.uid }
    
    private init() {}
    
    func signUp(email: String, password: String) async throws {
        let authResult = try await auth.createUser(withEmail: email, password: password)
        guard let email = authResult.user.email else { throw AuthError.noEmail }
        print("User with email '\(email)' is registered with id '\(authResult.user.uid)'")
        try await self.signIn(email: email, password: password)
    }
    
    func signIn(email: String, password: String) async throws {
        let authResult = try await auth.signIn(withEmail: email, password: password)
        guard let email = authResult.user.email else { throw AuthError.noEmail }
        print("User with email '\(email)' signed in with id '\(authResult.user.uid)'")
    }
    
    func signOut() throws {
        try auth.signOut()
        print("Sign out succeeded.")
    }
}

enum AuthError: LocalizedError {
    case noEmail
    case notAuthenticated
    
    var errorDescription: String? {
        switch self {
        case .noEmail:
            return "No email was found on newly created user."
        case .notAuthenticated:
            return "The user is not authenticated."
        }
    }
    
    var failureReason: String? {
        switch self {
        case .noEmail:
            return "The email address is missing."
        case .notAuthenticated:
            return "The user is not logged in."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .noEmail:
            return "Please provide a valid email address."
        case .notAuthenticated:
            return "Please log in to continue."
        }
    }
}

