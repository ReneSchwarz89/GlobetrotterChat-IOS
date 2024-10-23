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
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isCreateButtonEnabled = false
    @State private var isSearchEnabled = false
    @State private var searchQuery: String = ""

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
                            TextField("Group Name", text: $viewModel.groupName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.leading, 10)
                                .onChange(of: viewModel.groupName) { oldValue, newValue in
                                    updateCreateButtonState()
                                }
                        }
                    }
                }
                Section(header: Text("Select Contacts")) {
                    if isSearchEnabled {
                        TextField("Search Contacts", text: $searchQuery)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                    }
                    
                    List(viewModel.possibleContacts.filter { contact in
                        searchQuery.isEmpty ? true : contact.nickname.lowercased().contains(searchQuery.lowercased())
                    }, id: \.contactID) { contact in
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
                            Spacer()
                            if viewModel.selectedContacts.contains(contact.contactID) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.toggleContactSelection(contactID: contact.contactID)
                            updateCreateButtonState()
                        }
                    }
                }
            }
            .navigationTitle("New Chat Group")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.resetSelections()
                        viewModel.isAddChatGroupSheetPresented = false
                    }
                    .tint(Color("ArcticBlue"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            isSearchEnabled.toggle()
                        }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color("ArcticBlue").opacity(isSearchEnabled ? 1.0 : 0.3))
                        }
                        Button("Create") {
                            if let image = selectedImage {
                                viewModel.uploadGroupImage(image.jpegData(compressionQuality: 0.8)!)
                            }
                            viewModel.createChatGroup()
                            viewModel.resetSelections()
                            viewModel.isAddChatGroupSheetPresented = false
                        }
                        .tint(Color("ArcticBlue"))
                        .disabled(!isCreateButtonEnabled)
                    }
                }
            }
            .sheet(isPresented: $isImagePickerPresented, onDismiss: uploadImage) {
                ImagePicker(image: $selectedImage)
            }
        }
        .tint(Color("ArcticBlue"))
    }

    func uploadImage() {
        guard let selectedImage = selectedImage else { return }
        if let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
            viewModel.uploadGroupImage(imageData)
        }
        updateCreateButtonState()
    }

    func updateCreateButtonState() {
        if viewModel.selectedContacts.count == 1 {
            isCreateButtonEnabled = true
        } else if viewModel.selectedContacts.count > 1 && selectedImage != nil && !viewModel.groupName.isEmpty {
            isCreateButtonEnabled = true
        } else {
            isCreateButtonEnabled = false
        }
    }
}

#Preview {
    AddChatGroupSheet(viewModel: ChatGroupsViewModel(manager: FirebaseChatGroupsManager(uid: AuthServiceManager.shared.userID ?? "DYa1BIZI7HPeB5lLO6HfQy9dTsN2")))
}
