//
//  ContactRequestView.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 27.09.24.
//

import SwiftUI

struct ContactRequestView: View {
    @State private var isSheetPresented = false
    @Bindable var viewModel : ContactViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                // Deine Kontaktliste hier
                Text("Contact List")
                
                // Plus-Button oben rechts
                .navigationBarItems(trailing: Button(action: {
                    isSheetPresented = true
                }) {
                    Image(systemName: "plus")
                })
            }
            .sheet(isPresented: $isSheetPresented) {
                VStack {
                    TextField("Enter Token", text: $viewModel.token)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Send Request") {
                        viewModel.sendContactRequest()
                        isSheetPresented = false
                    }
                    .padding()
                }
                .padding()
            }
            .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK")) {
                        viewModel.errorMessage = nil
                        isSheetPresented = false
                    }
                )
            }
        }
    }
}


