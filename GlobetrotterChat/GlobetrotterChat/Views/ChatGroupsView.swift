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
                // Inhalt der View
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

