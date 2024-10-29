//
//  FirebaseStorageManager.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 07.10.24.
//

import Foundation
import FirebaseStorage

class FirebaseStorageManager {
    static let shared = FirebaseStorageManager()
    
    private let storage = Storage.storage()
    
    private init() {}
    
    func uploadImage(_ imageData: Data, path: String) async throws -> URL {
        let storageRef = storage.reference().child(path)
        _ = try await storageRef.putDataAsync(imageData, metadata: nil)
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL
    }
    
    func downloadImage(path: String) async throws -> Data {
        let storageRef = storage.reference(forURL: path)
        let imageData = try await storageRef.getData(maxSize: 10 * 1024 * 1024)
        return imageData
    }
}

extension StorageReference {
    func putDataAsync(_ uploadData: Data, metadata: StorageMetadata?) async throws -> StorageMetadata {
        try await withCheckedThrowingContinuation { continuation in
            self.putData(uploadData, metadata: metadata) { metadata, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let metadata = metadata {
                    continuation.resume(returning: metadata)
                } else {
                    continuation.resume(throwing: NSError(domain: "FirebaseStorageManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
                }
            }
        }
    }
    
    func downloadURL() async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            self.downloadURL { url, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let url = url {
                    continuation.resume(returning: url)
                } else {
                    continuation.resume(throwing: NSError(domain: "FirebaseStorageManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
                }
            }
        }
    }
    
    func getData(maxSize: Int64) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            self.getData(maxSize: maxSize) { data, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: NSError(domain: "FirebaseStorageManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
                }
            }
        }
    }
}
