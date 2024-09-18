//
//  ProfileView.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 08.09.24.
//
import SwiftUI

import SwiftUI
import Observation

struct ProfileView: View {
    @State private var errorMessage: String?
    @State private var isPresentingError = false
    var body: some View {
        NavigationStack{
            VStack {
                Button("Print Personal Data") {
                    print(AuthServiceManager.shared.isUserSignedIn)
                    print(AuthServiceManager.shared.userID as Any)
                    print(AuthServiceManager.shared.onBoardingStatus)
                }
                Text("User Profile")
                Button("Sign Out") {
                                do {
                                    try AuthServiceManager.shared.signOut()
                                    print(AuthServiceManager.shared.isUserSignedIn)
                                    print(AuthServiceManager.shared.userID as Any)
                                    print(AuthServiceManager.shared.onBoardingStatus)
                                } catch {
                                    print("Error signing out: \(error)")
                                }
                            }
            }
            .alert(isPresented: $isPresentingError) {
                Alert(title: Text("Error"), message: Text(errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
            }
        }
    }
}


#Preview {
    ProfileView()
}
