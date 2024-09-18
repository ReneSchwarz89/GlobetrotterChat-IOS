//
//  NavTabView.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 14.09.24.
//

import SwiftUI
import Observation

enum Tab {
    case chats
    case contacts
    case profile
}

struct ContentView: View {
    @State var selectedTab: Tab = .chats
    private var authServiceManager = AuthServiceManager.shared
    
    var body: some View {
        if authServiceManager.isUserSignedIn != true {
            AuthenticationView()
        } else {
            TabView(selection: $selectedTab) {
                ChatsView()
                    .tabItem { Label("Chats", systemImage: "message") }
                    .tag(Tab.chats)
                
                ContactView()
                    .tabItem { Label("Contacts", systemImage: "person.2") }
                    .tag(Tab.contacts)
                
                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person") }
                    .tag(Tab.profile)
            }
            .onAppear {
                if authServiceManager.onBoardingStatus == .loggedIn {
                    $selectedTab.wrappedValue = .chats
                } else if authServiceManager.onBoardingStatus == .signedUpAndLoggedIn {
                    $selectedTab.wrappedValue = .profile
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
