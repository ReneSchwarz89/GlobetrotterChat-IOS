//
//  GlobetrotterChatApp.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 08.09.24.
//

import SwiftUI
import Firebase
import Observation

@main
struct GlobetrotterChatApp: App {
    
    private let authViewModel : AuthViewModel
    
    init() {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        authViewModel = AuthViewModel()
    }
 
    var body: some Scene {
        WindowGroup {
            if authViewModel.authState == .neutral {
                AuthenticationView(viewModel: authViewModel)
            } else {
                NavTabView()
            }
        }
        .environment(authViewModel)
    }
}

