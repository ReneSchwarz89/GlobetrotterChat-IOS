//
//  QRCodeSheet.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 03.11.24.
//

import SwiftUI

struct QRCodeSheet: View {
    @Bindable var viewModel: ContactViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("QR-Code")
                    .font(.headline)
                    .padding()

                // Platzhalter für den QR-Code
                Image(systemName: "qrcode")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()
                
                Spacer()
              
                Button(action: {
                    viewModel.copyUIDToClipboard()
                    viewModel.isQRCodeSheetPresented = false
                }) {
                    Text("Copy your Token")
                        .font(.headline)
                        .foregroundColor(.arcticBlue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(25)
                        .shadow(color: .arcticBlue, radius: 5)
                }
                .padding(.horizontal, 40)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.isQRCodeSheetPresented = false
                    }
                    .foregroundColor(Color("ArcticBlue"))
                }
            }
        }
    }
}

#Preview {
    QRCodeSheet(viewModel: ContactViewModel())
}
