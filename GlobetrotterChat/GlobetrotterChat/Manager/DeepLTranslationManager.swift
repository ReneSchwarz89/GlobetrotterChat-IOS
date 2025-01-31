//
//  DeepLTranslationManager.swift
//  GlobetrotterChat
//
//  Created by René Schwarz on 29.10.24.
//

import Foundation

enum DeepLTranslationError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case missingAPIKey
    case unknownError
}

class DeepLTranslationManager {
    static let shared = DeepLTranslationManager()
    let apiKey = ProcessInfo.processInfo.environment["DEEPL_API_KEY"] ?? ""

    func translateText(text: String, targetLangs: [String]) async throws -> [TranslationResponse] {
        guard !apiKey.isEmpty else {
            throw DeepLTranslationError.missingAPIKey
        }

        var translationResponses: [TranslationResponse] = []
        for targetLang in targetLangs {
            var components = URLComponents(string: "https://api-free.deepl.com/v2/translate")!
            components.queryItems = [
                URLQueryItem(name: "auth_key", value: apiKey),
                URLQueryItem(name: "text", value: text),
                URLQueryItem(name: "target_lang", value: targetLang)
            ]

            guard let url = components.url else {
                throw DeepLTranslationError.invalidURL
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

            let (data, _) = try await URLSession.shared.data(for: request)

            do {
                let response = try JSONDecoder().decode(TranslationResponse.self, from: data)
                translationResponses.append(response)
            } catch let error {
                throw DeepLTranslationError.decodingError(error)
            }
        }

        return translationResponses
    }
}


struct TranslationResponse: Codable {
    let translations: [Translation]
}

struct Translation: Codable {
    let detectedSourceLanguage: String?
    let text: String
}
