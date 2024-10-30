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

    init(chatGroup: ChatGroup) {
        self.chatGroup = chatGroup
        _viewModel = State(wrappedValue: ChatViewModel(manager: FirebaseMessagesManager(), chatGroupID: chatGroup.id))
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
            
            ScrollView {
                VStack {
                    ForEach(viewModel.messages) { message in
                        HStack {
                            if message.senderId == AuthServiceManager.shared.user?.uid {
                                Spacer()
                                Text(message.text)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .frame(maxWidth: 250, alignment: .trailing)
                            } else {
                                Text(message.text)
                                    .padding()
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .frame(maxWidth: 250, alignment: .leading)
                                Spacer()
                            }
                        }
                        .padding(message.senderId == AuthServiceManager.shared.user?.uid ? .leading : .trailing, 50)
                        .padding(.vertical, 5)
                    }
                }
            }
            
            HStack {
                TextField("Nachricht eingeben...", text: $viewModel.newMessageText)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)

                Button(action: {
                    viewModel.sendMessage(chatGroupID: chatGroup.id, senderId: AuthServiceManager.shared.user?.uid ?? "")
                }) {
                    Text("Senden")
                        .padding()
                        .background(Color.green) // Farbe hier ändern
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

#Preview {
    let sampleChatGroup = ChatGroup(
        id: "sampleID",
        participants: ["userID1", "userID2"],
        isGroup: true,
        admin: "userID1",
        groupName: "Sample Group",
        groupPictureURL: "https://example.com/sample.jpg"
    )
    ChatView(chatGroup: sampleChatGroup)
}
