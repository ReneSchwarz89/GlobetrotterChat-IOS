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
        VStack {
            HStack {
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
                Text(chatGroup.groupName ?? "Chat Group Details")
                    .font(.title)
                    .padding()
                Spacer()
            }
            .padding(.horizontal, 16)
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack {
                        ForEach(viewModel.messages) { message in
                            HStack {
                                if message.senderId == viewModel.uid {
                                    Spacer()
                                    Text(message.text)
                                        .padding()
                                        .background(Color.arcticBlue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .frame(maxWidth: 250, alignment: .trailing)
                                } else {
                                    // Hole die `targetLanguageCode` des Empfängers
                                    let targetLanguageCode = chatGroup.participants.first(where: { $0.id == viewModel.uid })?.targetLanguageCode ?? "EN"
                                    Text(message.translations[targetLanguageCode] ?? message.text)
                                        .padding()
                                        .background(Color.arcticBlue.opacity(0.5))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .frame(maxWidth: 250, alignment: .leading)
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
            
            HStack {
                TextField("Nachricht eingeben...", text: $viewModel.newMessageText)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                
                Button(action: {
                    viewModel.sendMessage(chatGroup: chatGroup)
                }) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(viewModel.newMessageText.isEmpty ? Color.gray : Color.arcticBlue) // Hintergrundfarbe ändern
                        .frame(width: 52, height: 52) // Größe des Rechtecks
                        .overlay(
                            Image(systemName: "paperplane.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(Color.white)
                        )
                }
                .disabled(viewModel.newMessageText.isEmpty) // Deaktiviert den Button, wenn das Textfeld leer ist
            }
            .padding()
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    ChatView(chatGroup: ChatGroup(id: "1", participants: [], isGroup: true, admin: nil, groupName: "Test Group", groupPictureURL: nil))
}

