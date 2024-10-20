//
//  Profile.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 19.09.24.
//
import Foundation

struct Contact: Codable {
    
    var contactID: String
    var nickname: String
    var nativeLanguage: String
    var profileImage: String?
    
    init(contactID: String, nickname: String, nativeLanguage: String, profileImage: String? = nil) {
        self.contactID = contactID
        self.nickname = nickname
        self.nativeLanguage = nativeLanguage
        self.profileImage = profileImage
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "contactID": contactID,
            "nickname": nickname,
            "nativeLanguage": nativeLanguage,
            "profileImage": profileImage ?? ""
        ]
    }
}

extension Contact {
    static func sample() -> Contact {
        .init(contactID: "",nickname: "New User", nativeLanguage: "de", profileImage: nil)
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
