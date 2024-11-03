//
//  ContactView.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 13.09.24.
//

import Foundation
import SwiftUI

struct ContactView: View {
    @State var viewModel: ContactViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                List(viewModel.acceptedContacts, id: \.contactID) { contact in
                    HStack {
                        if let profileImage = contact.profileImage, !profileImage.isEmpty {
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
                                let newRequest = ContactRequest(from: viewModel.uid, to: contact.contactID, status: .blocked)
                                viewModel.updateRequestStatus(request: newRequest, to: .blocked)
                            }
                        } label: {
                            Label("Block", systemImage: "hand.raised.fill")
                        }
                    }
                }
                .navigationBarItems(leading: HStack {
                    Button(action: {
                        if !viewModel.blockedContacts.isEmpty {
                            viewModel.isBlockedContactsSheetPresented = true
                        }
                    }) {
                        Text("Blocked Contacts")
                            .foregroundColor(viewModel.blockedContacts.isEmpty ? .gray : Color.arcticBlue)
                    }
                    .disabled(viewModel.blockedContacts.isEmpty)
                    .sheet(isPresented: $viewModel.isBlockedContactsSheetPresented) {
                        BlockedContactsSheet(viewModel: viewModel)
                    }
                })
                .navigationBarItems(trailing: HStack {
                    Button(action: {
                        viewModel.isSendRequestSheetPresented = true
                    }) {
                        Image(systemName: "plus")
                    }
                    Button(action: {
                        viewModel.isQRCodeSheetPresented = true
                    }) {
                        Image(systemName: "qrcode")
                    }
                    .sheet(isPresented: $viewModel.isQRCodeSheetPresented) {
                        QRCodeSheet(viewModel: viewModel)
                    }
                    
                    if viewModel.newRequestCount > 0 {
                        Text("\(viewModel.newRequestCount)")
                            .foregroundColor(.red)
                            .padding(5)
                            .background(Circle().fill(Color.red))
                    }
                })
            }
            .sheet(isPresented: $viewModel.isSendRequestSheetPresented, onDismiss: { viewModel.isSendRequestSheetPresented = false }) {
                SendRequestSheet(viewModel: viewModel)
                    .presentationDetents([.medium])
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
    ContactView(viewModel: ContactViewModel(manager: FirebaseContactManager()))
        .accentColor(Color("ArcticBlue"))
}
