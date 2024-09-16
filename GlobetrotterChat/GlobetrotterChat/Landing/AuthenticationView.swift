//
//  ContentView.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 08.09.24.
//

import SwiftUI

struct AuthenticationView: View {
    @State private var isPasswordVisible: Bool = false
    @State private var hasPressedSignUp = false
    @State private var hasPressedSignIn = false
    @State private var lastErrorMessage = ""
    @State private var isPresentingError = false
    @Bindable var viewModel : AuthViewModel
    
    var body: some View {
        NavigationStack() {
            ZStack {
                // Hintergrundbild
                Image("loginBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    
                    Text("Welcome To The")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(.green)
                        .background(.white)
                    
                    Text("GlobetrotterChat")
                        .font(.system(size: 40, weight: .black))
                        .foregroundColor(.green)
                        .background(.white)
                    
                    Spacer()
                    
                    
                    // Textfelder und Button
                    VStack(spacing: 20) {
                        // E-Mail-Textfeld
                        TextField("Email Address", text: $viewModel.email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        
                        // Passwort-Textfeld mit der Option, das Passwort anzuzeigen
                        HStack {
                            if isPasswordVisible {
                                TextField("Password", text: $viewModel.password)
                                    .padding()
                                    .frame(height: 50)
                            } else {
                                SecureField("Password", text: $viewModel.password)
                                    .padding()
                                    .frame(height: 50)
                            }
                            
                            Button(action: {
                                // Umschalten der Sichtbarkeit des Passworts
                                self.isPasswordVisible.toggle()
                            }) {
                                Image(systemName: self.isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(self.isPasswordVisible ? Color.green : .gray.opacity(0.7))
                                    .padding(.trailing)
                            }
                        }
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        
                        Button(action: {
                            viewModel.signUp(email: viewModel.email, password: viewModel.password)
                        }) {
                            ZStack {
                                HStack {
                                    Spacer()
                                    if hasPressedSignUp {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .padding(.trailing, 16)
                                    }
                                }
                                Text("Sign Up")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                            }
                            .frame(height: 50)
                            .background(Color.green.opacity(0.7))
                            .cornerRadius(25)
                            .shadow(radius: 5)
                        }
                        .disabled(hasPressedSignUp)
                    }
                    .padding(.horizontal, 40)
                    
                    // Sign In Button
                    Button(action: {
                        viewModel.signIn(email: viewModel.email, password: viewModel.password)
                    }) {
                        ZStack {
                            HStack {
                                Spacer()
                                if hasPressedSignIn {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                                        .padding(.trailing, 16)
                                }
                            }
                            Text("Sign In")
                                .font(.headline)
                                .foregroundColor(.green)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .frame(height: 50)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(25)
                        .shadow(radius: 5)
                    }
                    .disabled(hasPressedSignIn)
                    .padding(.horizontal, 40)
                    .padding(.top, 40)
                    
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    AuthenticationView(viewModel: AuthViewModel())
}
