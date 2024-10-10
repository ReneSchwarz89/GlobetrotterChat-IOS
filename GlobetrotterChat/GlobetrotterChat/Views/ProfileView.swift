//
//  ProfileView.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 08.09.24.
//


import SwiftUI
import Observation
import FirebaseStorage

struct ProfileView: View {
    
    @State var viewModel: ProfileViewModel
    @State var isImagePickerPresented: Bool = false
    @State private var errorMessage: String?
    @State private var isPresentingError = false
    @State private var selectedImage: UIImage?
    let languages = ["English", "Deutsch", "Español", "Français", "中文", "日本語", "한국어", "Italiano"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                // Profilbild
                Button(action: {
                    self.isImagePickerPresented = true
                }) {
                    ZStack {
                        if let profileImageData = viewModel.profileImageData, let uiImage = UIImage(data: profileImageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .onAppear{
                                    print("Displaying profile image")
                                }
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .foregroundColor(.gray)
                                .onAppear{
                                    print("Displaying placeholder image")
                                }
                        }
                    }
                }
                .frame(width: 180, height: 180)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 10)
                .sheet(isPresented: $isImagePickerPresented, onDismiss: loadImage) {
                    ImagePicker(image: $selectedImage)
                }
                
                // Nickname-Textfeld
                TextField("Nickname", text: $viewModel.nickname)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                
                // Native Language Picker mit Beschriftung und Hintergrund
                Text("Native Language")
                    .font(.headline)
                    .foregroundColor(.arcticBlue)
                    .padding(.bottom, 5)
                
                Picker("Native Language", selection: $viewModel.nativeLanguage) {
                    ForEach(languages, id: \.self) { language in
                        Text(language).tag(language)
                            .foregroundColor(.arcticBlue)
                            .font(.system(size: 22, weight: .bold))
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.8)))
                .shadow(radius: 5)
                
                Button(action: {
                    viewModel.saveProfile()
                }) {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.arcticBlue.opacity(0.7))
                        .cornerRadius(25)
                        .shadow(radius: 5)
                }
                
                Button(action: {
                    do {
                        try AuthServiceManager.shared.signOut()
                    } catch {
                        print("Error signing out: \(error)")
                    }
                }) {
                    Text("Logout")
                        .font(.headline)
                        .foregroundColor(.arcticBlue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(25)
                        .shadow(color: .arcticBlue, radius: 5)
                }
            }
            .padding(.horizontal, 40)
            .alert(isPresented: $isPresentingError) {
                Alert(title: Text("Error"), message: Text(errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
            }
            .onAppear { viewModel.loadProfile() }
        }
    }
    
    func loadImage() {
        guard let selectedImage = selectedImage else { return }
        if let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
            viewModel.uploadProfileImage(imageData)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

#Preview {
    ProfileView(viewModel: ProfileViewModel(manager: FirebaseProfileManager(uid: "XImrbbVdfXPCJwBRKcxF5i8VEzx1")))
}


