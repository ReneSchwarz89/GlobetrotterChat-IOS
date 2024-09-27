//
//  ContactView.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 13.09.24.
//

import SwiftUI

struct ContactView: View {
    @State var viewModel: ContactViewModel
    @State private var isSheetPresented = false
    
    var body: some View {
        NavigationStack {
            VStack {
                List(viewModel.acceptedContacts, id: \.contactID) { contact in
                    HStack {
                        if let profileImage = contact.profileImage, !profileImage.isEmpty {
                            // Lade das Profilbild
                            AsyncImage(url: URL(string: profileImage)) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 50, height: 50)
                            }
                        } else {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 50, height: 50)
                        }
                        VStack(alignment: .leading) {
                            Text(contact.nickname)
                                .font(.headline)
                            Text(contact.nativeLanguage)
                                .font(.subheadline)
                        }
                    }
                }
                
                // Plus-Button oben rechts
                .navigationBarItems(trailing: HStack {
                    Button(action: {
                        isSheetPresented = true
                    }) {
                        Image(systemName: "plus")
                    }
                    
                    if viewModel.newRequestCount > 0 {
                        Text("\(viewModel.newRequestCount)")
                            .foregroundColor(.red)
                            .padding(5)
                            .background(Circle().fill(Color.red))
                    }
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
                    }
                )
            }
            .alert(isPresented: .constant(viewModel.pendingRequests.count > 0)) {
                Alert(
                    title: Text("New Contact Request"),
                    message: Text("Do you want to accept the request from \(viewModel.pendingRequests.first?.from ?? "Unknown")?"),
                    primaryButton: .default(Text("Accept")) {
                        if let request = viewModel.pendingRequests.first {
                            viewModel.updateRequestStatus(request: request, to: .allowed)
                        }
                    },
                    secondaryButton: .cancel(Text("Decline")) {
                        if let request = viewModel.pendingRequests.first {
                            viewModel.updateRequestStatus(request: request, to: .blocked)
                        }
                    }
                )
            }
            .onAppear {
                // Überprüfen, ob es neue Anfragen gibt
                if viewModel.pendingRequests.first != nil {
                    // Logik zum Anzeigen der Anfrage
                }
            }
            .navigationTitle("Contacts")
        }
        
    }
}
