//
//  BlockedContactsSheet.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 03.11.24.
//

import SwiftUI

struct BlockedContactsSheet: View {
    @Bindable var viewModel: ContactViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("Blocked Contacts")
                    .font(.headline)
                    .padding()
                List(viewModel.blockedContacts, id: \.contactID) { contact in
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
                    .background(Color.clear) // Entfernt den grauen Hintergrund
                    .listRowBackground(Color.arcticBlue.opacity(0.1)) // Entfernt den Hintergrund der List-Zeilen
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            if let request = viewModel.pendingRequests.first(where: { $0.to == contact.contactID || $0.from == contact.contactID }) {
                                viewModel.updateRequestStatus(request: request, to: .allowed)
                            } else {
                                let newRequest = ContactRequest(from: viewModel.uid, to: contact.contactID, status: .allowed)
                                viewModel.updateRequestStatus(request: newRequest, to: .allowed)
                            }
                        } label: {
                            Label("Unblock", systemImage: "hand.raised.fill")
                        }
                    }
                }
                .listStyle(InsetListStyle()) // Verwendet einfachen List-Stil ohne zusätzlichen Rand
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.isBlockedContactsSheetPresented = false
                    }
                    .foregroundColor(Color("ArcticBlue"))
                }
            }
        }
    }
}

#Preview {
    BlockedContactsSheet(viewModel: ContactViewModel())
}

