//
//  ContentView.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 08.09.24.
//

import SwiftUI
import Observation

struct AuthenticationView: View {
    @State private var isPasswordVisible: Bool = false
    @State private var hasPressedSignUp = false
    @State private var hasPressedSignIn = false
    @State private var lastErrorMessage = ""
    @State private var isPresentingError = false
    @State var viewModel = AuthViewModel()
    
    var body: some View {
        NavigationStack {
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
                        .foregroundColor(.arcticBlue)
                        .background(.white)
                    
                    Text("GlobetrotterChat")
                        .font(.system(size: 40, weight: .black))
                        .foregroundColor(.arcticBlue)
                        .background(.white)
                    Spacer()
                    
                    // Textfelder und Button
                    VStack(spacing: 20) {
                        // E-Mail-Textfeld
                        TextField("Email Address", text: $viewModel.email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
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
                            
                            Button(action: { self.isPasswordVisible.toggle() }) {
                                Image(systemName: self.isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(self.isPasswordVisible ? Color.green : .gray.opacity(0.7))
                                    .padding(.trailing)
                            }
                        }
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        
                        Button(action: {
                            hasPressedSignUp = true
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
                            .background(Color.arcticBlue.opacity(0.7))
                            .cornerRadius(25)
                            
                        }
                        .disabled(hasPressedSignUp)
                    }
                    .padding(.horizontal, 40)
                    
                    // Sign In Button
                    Button(action: {
                        hasPressedSignIn = true
                        viewModel.signIn(email: viewModel.email, password: viewModel.password)
                    }) {
                        ZStack {
                            HStack {
                                Spacer()
                                if hasPressedSignIn {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .arcticBlue))
                                        .padding(.trailing, 16)
                                }
                            }
                            Text("Sign In")
                                .font(.headline)
                                .foregroundColor(.arcticBlue)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .frame(height: 50)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(25)
                        .shadow(color: .arcticBlue, radius: 5)
                    }
                    .disabled(hasPressedSignIn)
                    .padding(40)
                    .padding(.top, 60)
                    .padding(.bottom, 60)
                        
                    
                }
                
                
            }
            
        }
        .alert(isPresented: .constant(viewModel.error != nil), error: viewModel.error) {
            Button("OK", role: .cancel) {
                viewModel.error = nil ;hasPressedSignUp = false ;hasPressedSignIn = false
            }
        }
    }
}

#Preview {
    AuthenticationView(viewModel: AuthViewModel())
}
