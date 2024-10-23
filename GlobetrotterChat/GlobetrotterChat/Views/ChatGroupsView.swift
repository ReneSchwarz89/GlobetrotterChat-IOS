//
//  ChatsView.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 13.09.24.
//

import SwiftUI
import Observation

struct ChatGroupsView: View {
    
    @State var viewModel = ChatGroupsViewModel()
    
    
    var body: some View {
        NavigationStack {
            VStack {
                List(viewModel.chatGroups) { chatGroup in // Neu
                    HStack {
                        if chatGroup.isGroup {
                            AsyncImage(url: URL(string: chatGroup.groupPictureURL ?? "")) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 50, height: 50)
                            }
                            Text(chatGroup.groupName ?? "Group")
                                .font(.headline)
                        } else {
                            if let contactID = chatGroup.participants.first(where: { $0 != AuthServiceManager.shared.user?.uid ?? "" }) {
                                if let contact = viewModel.possibleContacts.first(where: { $0.contactID == contactID }) {
                                    AsyncImage(url: URL(string: contact.profileImage ?? "")) { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                    } placeholder: {
                                        Circle()
                                            .fill(Color.gray)
                                            .frame(width: 50, height: 50)
                                    }
                                    Text(contact.nickname)
                                        .font(.headline)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Chats")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            viewModel.isAddChatGroupSheetPresented = true
                        }) {
                            Image(systemName: "plus")
                        }
                        
                    }
                }
            }
            .sheet(isPresented: $viewModel.isAddChatGroupSheetPresented) {
                AddChatGroupSheet(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ChatGroupsView(viewModel: ChatGroupsViewModel(manager: FirebaseChatGroupsManager(uid: AuthServiceManager.shared.userID ?? "DYa1BIZI7HPeB5lLO6HfQy9dTsN2")))
}

