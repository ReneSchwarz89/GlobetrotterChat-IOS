//
//  ChatView.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 15.10.24.
//

import SwiftUI

struct ChatView: View {
    @State var viewModel: ChatViewModel
    let chatGroup: ChatGroup
    @State private var scrollViewProxy: ScrollViewProxy? = nil

    init(chatGroup: ChatGroup) {
        self.chatGroup = chatGroup
        _viewModel = State(wrappedValue: ChatViewModel(manager: FirebaseMessagesManager(), chatGroup: chatGroup))
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Toolbar mit dem Gruppenbild und Namen
                HStack {
                    if chatGroup.isGroup {
                        AsyncImage(url: URL(string: chatGroup.groupPictureURL ?? "")) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } placeholder: {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 40, height: 40)
                        }
                        Text(chatGroup.groupName ?? "Chat Group")
                            .font(.title2)
                            .padding(.leading, 8)
                    } else {
                        if let otherParticipant = chatGroup.participants.first(where: { $0.id != viewModel.uid }) {
                            if let contact = viewModel.possibleContacts.first(where: { $0.contactID == otherParticipant.id }) {
                                AsyncImage(url: URL(string: contact.profileImage ?? "")) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                    case .failure:
                                        Circle()
                                            .fill(Color.gray)
                                            .frame(width: 40, height: 40)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                Text(contact.nickname)
                                    .font(.headline)
                                    .padding(.leading, 8)
                            }
                        }
                    }
                    Spacer()
                }
                .padding()

                // Nachrichtenanzeige
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack {
                            ForEach(viewModel.messages) { message in
                                HStack {
                                    if message.senderId == viewModel.uid {
                                        Spacer()
                                        VStack(alignment: .trailing) {
                                            Text(message.text)
                                                .padding()
                                                .background(Color.arcticBlue)
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                                .frame(maxWidth: 250, alignment: .trailing)
                                        }
                                    } else {
                                        let nickname = chatGroup.participants.first(where: { $0.id == message.senderId })?.nickname ?? "Unknown"
                                        let targetLanguageCode = chatGroup.participants.first(where: { $0.id == viewModel.uid })?.targetLanguageCode ?? "EN"
                                        VStack(alignment: .leading) {
                                            Text(message.translations[targetLanguageCode] ?? message.text)
                                                .padding()
                                                .background(Color.arcticBlue.opacity(0.5))
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                                .frame(maxWidth: 250, alignment: .leading)
                                            
                                            if chatGroup.isGroup {
                                                Text(nickname)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                                    .padding([.top], 5)
                                            }
                                        }
                                        Spacer()
                                    }
                                }
                                .padding(message.senderId == viewModel.uid ? .leading : .trailing, 50)
                                .padding(.vertical, 5)
                            }
                            .padding(.horizontal, 12)
                        }
                        .onChange(of: viewModel.messages.count) { _, newValue in
                            if let lastMessage = viewModel.messages.last {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                    .onAppear {
                        self.scrollViewProxy = proxy
                    }
                }

                // Textfeld und Senden-Button unten fixieren
                HStack {
                    TextField("Nachricht eingeben...", text: $viewModel.newMessageText)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    
                    Button(action: {
                        viewModel.sendMessage(chatGroup: chatGroup)
                    }) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(viewModel.newMessageText.isEmpty ? Color.gray : Color.arcticBlue)
                            .frame(width: 52, height: 52)
                            .overlay(
                                Image(systemName: "paperplane.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(Color.white)
                            )
                    }
                    .disabled(viewModel.newMessageText.isEmpty)
                }
                .padding()
                .background(Color.white)
                .shadow(color: .gray, radius: 2, x: 0, y: -2)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    ChatView(chatGroup: ChatGroup(id: "1", participants: [], isGroup: true, admin: nil, groupName: "Test Group", groupPictureURL: nil))
}

