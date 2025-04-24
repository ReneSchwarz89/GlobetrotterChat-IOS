//
//  ChatsView.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 13.09.24.
//

import SwiftUI
import Observation

struct ChatGroupsView: View {
    @Bindable var viewModel: ChatGroupsViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                List(viewModel.chatGroups) { chatGroup in
                    NavigationLink(destination: ChatView(chatGroup: chatGroup)
                        .onAppear { viewModel.tabBar.isHidden = true }
                        .onDisappear { viewModel.tabBar.isHidden = false }) {
                            HStack {
                                if chatGroup.isGroup {
                                    if let url = URL(string: chatGroup.groupPictureURL ?? "") {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                            case .success(let image):
                                                image.resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 50, height: 50)
                                                    .clipShape(Circle())
                                            case .failure:
                                                Circle()
                                                    .fill(Color.gray)
                                                    .frame(width: 50, height: 50)
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    } else {
                                        Circle()
                                            .fill(Color.gray)
                                            .frame(width: 50, height: 50)
                                    }
                                    Text(chatGroup.groupName ?? "Group")
                                        .font(.headline)
                                } else {
                                    if let contactID = chatGroup.participants.first(where: { $0.id != viewModel.uid })?.id {
                                        if let contact = viewModel.possibleContacts.first(where: { $0.contactID == contactID }) {
                                            if let url = URL(string: contact.profileImage ?? "") {
                                                AsyncImage(url: url) { phase in
                                                    switch phase {
                                                    case .empty:
                                                        ProgressView()
                                                    case .success(let image):
                                                        image.resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                            .frame(width: 50, height: 50)
                                                            .clipShape(Circle())
                                                    case .failure:
                                                        Circle()
                                                            .fill(Color.gray)
                                                            .frame(width: 50, height: 50)
                                                    @unknown default:
                                                        EmptyView()
                                                    }
                                                }
                                            } else {
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
                .background(TabBarAccessor { tabbar in
                    viewModel.tabBar = tabbar
                })
                .onAppear {
                    viewModel.isTabBarVisible = true
                    viewModel.setupListeners()
                }
            }
        }
    }
}

#Preview {
    ChatGroupsView(viewModel: ChatGroupsViewModel())
}

struct TabBarAccessor: UIViewControllerRepresentable {
    var callback: (UITabBar) -> Void
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<TabBarAccessor>) -> UIViewController {
        let viewController = UIViewController()
        DispatchQueue.main.async {
            if let tabBarController = viewController.tabBarController {
                self.callback(tabBarController.tabBar)
            }
        }
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<TabBarAccessor>) {}
}
