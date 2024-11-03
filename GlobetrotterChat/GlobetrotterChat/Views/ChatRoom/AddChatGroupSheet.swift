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
            Text("Create Chat Group")
                .font(.headline)
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
                        contact.contactID != viewModel.uid && (searchQuery.isEmpty ? true : contact.nickname.lowercased().contains(searchQuery.lowercased()))
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
                            Image(systemName: viewModel.selectedContacts.contains(contact.contactID) ? "checkmark.circle.fill" : "checkmark.circle")
                                .foregroundColor(viewModel.selectedContacts.contains(contact.contactID) ? Color("ArcticBlue") : Color.gray)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.toggleContactSelection(contactID: contact.contactID)
                            updateCreateButtonState()
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.resetSelections()
                        viewModel.isAddChatGroupSheetPresented = false
                    }
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
                        }
                        .disabled(!isCreateButtonEnabled)
                    }
                }
            }
            .sheet(isPresented: $isImagePickerPresented, onDismiss: uploadImage) {
                ImagePicker(image: $selectedImage)
            }
            
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Alert"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
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
    AddChatGroupSheet(viewModel: ChatGroupsViewModel())
}
