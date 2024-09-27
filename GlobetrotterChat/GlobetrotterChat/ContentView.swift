//
//  NavTabView.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 14.09.24.
//

import SwiftUI
import Observation

enum Tab: Int {
    case chats
    case contacts
    case profile
}

struct ContentView: View {
    @State var selectedTab: Tab = UserDefaults.standard.selectedTab
    private var authServiceManager = AuthServiceManager.shared
    
    var body: some View {
        if authServiceManager.isUserSignedIn != true {
            AuthenticationView()
        } else {
            TabView(selection: $selectedTab) {
                ChatsView()
                    .tabItem { Label("Chats", systemImage: "message") }
                    .tag(Tab.chats)
                
                ContactView(viewModel: ContactViewModel(manager: FirebaseContactManager()))
                    .tabItem { Label("Contacts", systemImage: "person.2") }
                    .tag(Tab.contacts)
                
                ProfileView(viewModel: ProfileViewModel(manager: FirebaseProfileManager(uid: "\(AuthServiceManager.shared.user?.uid ?? "")")))
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
            .onChange(of: selectedTab) { oldvalue, newValue in
                UserDefaults.standard.selectedTab = newValue
            }
        }
    }
}

extension UserDefaults {
    private enum Keys {
        static let selectedTab = "selectedTab"
    }
    
    var selectedTab: Tab {
        get {
            let rawValue = integer(forKey: Keys.selectedTab)
            return Tab(rawValue: rawValue) ?? .chats
        }
        set {
            set(newValue.rawValue, forKey: Keys.selectedTab)
        }
    }
}

#Preview {
    ContentView()
}
