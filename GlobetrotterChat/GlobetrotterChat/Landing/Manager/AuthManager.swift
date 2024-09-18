//
//  Repository.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 16.09.24.
//

import Foundation
import FirebaseAuth
import Observation

enum OnboardingStatus: Equatable {
    case neutral
    case loggedIn
    case signedUpAndLoggedIn
}

protocol AuthManager {
    var isUserSignedIn: Bool { get }
    var userID: String? { get }
    var onBoardingStatus: OnboardingStatus { get set }
    
    func signUp(email: String, password: String) async throws
    func signIn(email: String, password: String) async throws
    func signOut() throws
}

