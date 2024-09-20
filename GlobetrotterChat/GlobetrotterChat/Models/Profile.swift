//
//  Profile.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 19.09.24.
//
import Foundation
import UIKit

struct Profile: Codable {
    var nickname: String
    var nativeLanguage: String
    var profileImage: String?
}

extension Profile {
    static func sample() -> Profile {
        .init(nickname: "New User", nativeLanguage: "de", profileImage: nil)
    }
}
/*
 

struct UIImageWrapper: Codable {
    var image: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case image
    }
    
    init(image: UIImage?){
        self.image = image
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let imageData = try container.decodeIfPresent(Data.self, forKey: .image) {
            self.image = UIImage(data: imageData)
        } else {
            self.image = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let imageData = image, let imageData = image?.pngData() {
            try container.encode(imageData, forKey: .image)
        }
    }
}
 */
