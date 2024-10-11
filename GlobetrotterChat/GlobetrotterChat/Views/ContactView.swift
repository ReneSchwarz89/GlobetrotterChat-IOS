//
//  ContactView.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 13.09.24.
//

import SwiftUI
import Observation

struct ContactView: View {
    @State var viewModel: ContactViewModel
    @State var isSendRequestSheetPresented = false
    @State var isBlockedContactsSheetPresented = false
    @State var isGlobalContactsSheetPresented = false
    
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
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            if let request = viewModel.pendingRequests.first(where: { $0.to == contact.contactID || $0.from == contact.contactID }) {
                                        viewModel.updateRequestStatus(request: request, to: .blocked)
                                    } else {
                                        // Falls keine Anfrage gefunden wird, erstelle eine neue Anfrage zum Blockieren
                                        let newRequest = ContactRequest(from: AuthServiceManager.shared.userID ?? "", to: contact.contactID, status: .blocked)
                                        viewModel.updateRequestStatus(request: newRequest, to: .blocked)
                                    }
                        } label: {
                            Label("Block", systemImage: "hand.raised.fill")
                        }
                    }
                }
                
                // Plus-Button oben rechts
                .navigationBarItems(trailing: HStack {
                    Button(action: {
                        isSendRequestSheetPresented = true
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
                
                // Neue Buttons für Blocked Contacts und Global Contacts
                .navigationBarItems(leading: HStack {
                    Button(action: {
                        isBlockedContactsSheetPresented = true
                    }) {
                        Text("Blocked Contacts")
                    }
                    .sheet(isPresented: $isBlockedContactsSheetPresented) {
                        VStack {
                            Text("Blocked Contacts")
                                .font(.headline)
                                .padding()
                            Spacer()
                            List(viewModel.blockedContacts, id: \.contactID) { contact in
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
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        if let request = viewModel.pendingRequests.first(where: { $0.to == contact.contactID || $0.from == contact.contactID }) {
                                            viewModel.updateRequestStatus(request: request, to: .allowed)
                                                } else {
                                                    // Falls keine Anfrage gefunden wird, erstelle eine neue Anfrage zum Blockieren
                                                    let newRequest = ContactRequest(from: AuthServiceManager.shared.userID ?? "", to: contact.contactID, status: .blocked)
                                                    viewModel.updateRequestStatus(request: newRequest, to: .allowed)
                                                }
                                    } label: {
                                        Label("Unblock", systemImage: "hand.raised.fill")
                                    }
                                }
                            }
                        }
                    }
                    
                    Button(action: {
                        isGlobalContactsSheetPresented = true
                    }) {
                        Text("Global Contacts")
                    }
                    .sheet(isPresented: $isGlobalContactsSheetPresented) {
                        VStack {
                            Text("Global Contacts")
                                .font(.headline)
                                .padding()
                            Spacer()
                        }
                    }
                })
            }
            .sheet(isPresented: $isSendRequestSheetPresented) {
                VStack {
                    TextField("Enter Token", text: $viewModel.sendToken)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Send Request") {
                        viewModel.sendContactRequest()
                        isSendRequestSheetPresented = false
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
            .sheet(isPresented: $viewModel.showPendingRequestSheet) {
                VStack {
                    Text("New Contact Requests")
                        .font(.headline)
                        .padding()
                    
                    List(viewModel.pendingRequests, id: \.id) { request in
                        HStack {
                            Text(request.from)
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                viewModel.updateRequestStatus(request: request, to: .allowed)
                            }) {
                                Text("Accept")
                                    .foregroundColor(.green)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            Button(action: {
                                viewModel.updateRequestStatus(request: request, to: .blocked)
                            }) {
                                Text("Decline")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
                .padding()
            }
            .onAppear {
                viewModel.setupListeners()
            }
            .navigationTitle("Contacts")
        }
    }
}

#Preview {
    ContactView(viewModel: ContactViewModel(manager: FirebaseContactManager(uid: AuthServiceManager.shared.user?.uid ?? "XImrbbVdfXPCJwBRKcxF5i8VEzx1")))
}
