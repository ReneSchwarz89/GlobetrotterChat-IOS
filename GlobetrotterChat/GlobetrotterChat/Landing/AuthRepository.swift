//
//  Repository.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 16.09.24.
//

import Foundation
import Observation
import FirebaseAuth

enum AuthState: Equatable {
    case neutral
    case loggedIn
    case signedUpAndLoggedIn
}

protocol AuthRepository {
    var user: FirebaseAuth.User? { get }
    var isUserSignedIn: Bool { get }
    var userID: String? { get }
    
    func signUp(email: String, password: String) async throws
    func signIn(email: String, password: String) async throws
    func signOut() throws
}

class AuthRepositoryImpl: AuthRepository {
    private let authService = FirebaseAuthService.shared
    
    var user: FirebaseAuth.User? { authService.user }
    var isUserSignedIn: Bool { authService.isUserSignedIn }
    var userID: String? { authService.userID }
    
    func signUp(email: String, password: String) async throws {
        try await authService.signUp(email: email, password: password)
    }
    
    func signIn(email: String, password: String) async throws {
        try await authService.signIn(email: email, password: password)
    }
    
    func signOut() throws {
        try authService.signOut()
    }
}


