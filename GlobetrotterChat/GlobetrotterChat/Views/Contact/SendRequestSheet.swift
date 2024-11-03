//
//  SendRequestSheet.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 03.11.24.
//

import SwiftUI

struct SendRequestSheet: View {
    @Bindable var viewModel: ContactViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Add Contacts")
                    .font(.headline)
                    .padding()
                TextField("Enter Token", text: $viewModel.sendToken)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                Spacer()
                
                Button(action: {
                    viewModel.sendContactRequest()
                    viewModel.isSendRequestSheetPresented = false
                    viewModel.sendToken = ""
                }) {
                    Text("Send Request")
                        .font(.headline)
                        .foregroundColor(.arcticBlue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(viewModel.sendToken.isEmpty ? Color.arcticBlue.opacity(0.4) : Color.white.opacity(0.9))
                        .cornerRadius(25)
                        .shadow(color: .arcticBlue, radius: 5)
                }
                .padding(.horizontal, 40)
                .disabled(viewModel.sendToken.isEmpty)
                .opacity(viewModel.sendToken.isEmpty ? 0.374 : 1)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.isSendRequestSheetPresented = false
                        viewModel.sendToken = ""
                    }
                    .foregroundColor(Color("ArcticBlue"))
                    
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            // Kamera-Logik hier
                        }) {
                            Image(systemName: "camera")
                                .foregroundColor(Color("ArcticBlue"))
                        }
                        Button(action: {
                            if let pastText = UIPasteboard.general.string {
                                viewModel.sendToken = pastText
                            }
                        }) {
                            Text("Paste")
                                .foregroundColor(Color("ArcticBlue"))
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SendRequestSheet(viewModel: ContactViewModel())
}

