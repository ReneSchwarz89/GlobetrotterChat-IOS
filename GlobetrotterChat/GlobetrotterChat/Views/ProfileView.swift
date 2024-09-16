//
//  ProfileView.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 08.09.24.
//
import SwiftUI

import SwiftUI

struct ProfileView: View {
    
    @Environment(AuthViewModel.self) private var authViewModel
    
    var body: some View {
        VStack {
            Text("User Profile")
            Button("Sign Out") {
                authViewModel.signOut()
            }
        }
    }
}


#Preview {
    ProfileView()
}
