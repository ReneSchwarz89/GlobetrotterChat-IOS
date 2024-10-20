//
//  GlobetrotterChatApp.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 08.09.24.
//

import SwiftUI
import Firebase

@main
struct GlobetrotterChatApp: App {
    
    init() {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
    }
    
    var body: some Scene {
            WindowGroup {
                ContentView()
                    .accentColor(Color("ArcticBlue"))
            }
        }
}


