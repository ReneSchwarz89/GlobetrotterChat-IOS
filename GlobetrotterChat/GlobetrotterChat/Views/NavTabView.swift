//
//  NavTabView.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 14.09.24.
//

import SwiftUI

struct NavTabView: View {
    var body: some View {
        TabView {
            ChatsView().tabItem { Label("Chats", systemImage: "message") }
            ContactView().tabItem { Label("Contacts", systemImage: "person.2") }
            ProfileView().tabItem { Label("Profile", systemImage: "person") }
        }
    }
}

#Preview {
    NavTabView()
}
