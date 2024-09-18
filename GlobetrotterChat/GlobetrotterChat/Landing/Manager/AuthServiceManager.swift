//
//  FirebaseAuthManager.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 08.09.24.
//

import Foundation
import FirebaseAuth
import Observation


@Observable class AuthServiceManager: AuthManager {
    static var shared: AuthServiceManager = AuthServiceManager() // Singleton
    var onBoardingStatus: OnboardingStatus = .neutral
    
    private let auth = Auth.auth()
    private var user: FirebaseAuth.User?
    var isUserSignedIn: Bool { user != nil }
    var userID: String? { user?.uid }
    
    private init() {
        checkAuth()
    }
    
    func signUp(email: String, password: String) async throws {
        do {
            let authResult = try await auth.createUser(withEmail: email, password: password)
            guard let email = authResult.user.email else { throw AuthError.noEmail }
            print("User with email '\(email)' is registered with id '\(authResult.user.uid)'")
            try await self.signIn(email: email, password: password)
            self.onBoardingStatus = .signedUpAndLoggedIn
        } catch let error as NSError {
            if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                throw AuthError.emailAlreadyInUse
            } else {
                throw error
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        let authResult = try await auth.signIn(withEmail: email, password: password)
        guard let email = authResult.user.email else { throw AuthError.noEmail }
        print("User with email '\(email)' signed in with id '\(authResult.user.uid)'")
        self.user = authResult.user
        self.onBoardingStatus = .loggedIn
    }
    
    func signOut() throws {
        do {
            try auth.signOut()
            print("Sign out succeeded.")
            self.onBoardingStatus = .neutral
            self.user = nil
        } catch let error as NSError {
            if error.code == AuthErrorCode.notificationNotForwarded.code.rawValue {
                print("Sign out failed. The user has not been signed in.")
            } else {
                throw error
            }
        }
    }
    
    private func checkAuth() {
        guard let currentUser = auth.currentUser else {
            print("Not logged in")
            return
        }
        self.user = currentUser
    }
}

