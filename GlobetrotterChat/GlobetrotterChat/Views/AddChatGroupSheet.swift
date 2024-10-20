//
//  AddChatGroupSheet.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 18.10.24.
//

import SwiftUI
import Observation

struct AddChatGroupSheet: View {
    @Bindable var viewModel: ChatGroupsViewModel
    @State private var groupName: String = ""
    @State private var groupPictureURL: String = ""
    @State private var selectedImage: UIImage?
    @State private var isUploading = false
    @State private var isImagePickerPresented = false
    
    var body: some View {
        NavigationStack {
            Form {
                if viewModel.selectedContacts.count > 1 {
                    Section(header: Text("Group Details")) {
                        HStack {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        isImagePickerPresented = true
                                    }
                            } else {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 50, height: 50)
                                    .onTapGesture {
                                        isImagePickerPresented = true
                                    }
                            }
                            
                            TextField("Group Name", text: $groupName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.leading, 10)
                        }
                    }
                }
                
                Section(header: Text("Select Contacts")) {
                    List(viewModel.possibleContacts, id: \.contactID) { contact in
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
                            Spacer()
                            if viewModel.selectedContacts.contains(contact.contactID) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.toggleContactSelection(contactID: contact.contactID)
                        }
                    }
                }
                
            }
            .navigationTitle("New Chat Group")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.isAddChatGroupSheetPresented = false
                    }
                    .tint(Color("ArcticBlue"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        let isGroup = viewModel.selectedContacts.count > 1
                        viewModel.createChatGroup(participants: Array(viewModel.selectedContacts), isGroup: isGroup, groupName: groupName, groupPictureURL: groupPictureURL)
                        viewModel.isAddChatGroupSheetPresented = false
                    }
                    .tint(Color("ArcticBlue"))
                }
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(image: $selectedImage)
            }
        }
        .tint(Color("ArcticBlue"))
    }
}

#Preview {
    AddChatGroupSheet(viewModel: ChatGroupsViewModel(manager: FirebaseChatGroupsManager(uid: AuthServiceManager.shared.userID ?? "DYa1BIZI7HPeB5lLO6HfQy9dTsN2")))
}
