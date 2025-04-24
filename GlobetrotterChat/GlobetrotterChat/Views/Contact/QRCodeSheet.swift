//
//  QRCodeSheet.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 03.11.24.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeSheet: View {
    @Bindable var viewModel: ContactViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("QR-Code")
                    .font(.headline)
                    .padding()

                QRCodeView(uid: viewModel.uid)
                
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

struct QRCodeView: View {
    var uid: String
    @State private var qrCodeImage: UIImage?

    var body: some View {
        VStack {
            if let qrCodeImage = qrCodeImage {
                Image(uiImage: qrCodeImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()
            } else {
                Text("QR code is generated...")
                    .padding()
            }
        }
        .onAppear {
            generateQRCode()
        }
    }

    private func generateQRCode() {
        let data = uid.data(using: .ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            if let output = filter.outputImage {
                let transform = CGAffineTransform(scaleX: 10, y: 10)
                let scaledOutput = output.transformed(by: transform)
                let context = CIContext()
                if let cgImage = context.createCGImage(scaledOutput, from: scaledOutput.extent) {
                    self.qrCodeImage = UIImage(cgImage: cgImage)
                }
            }
        }
    }
}
