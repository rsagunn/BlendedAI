//
//  GeminiChatProvider.swift
//  BlendedAI
//

import Foundation
import FirebaseAILogic

enum GeminiErrorFormatter {
    static func message(for error: Error) -> String {
        if let error = error as? GenerateContentError {
            switch error {
            case .internalError(let underlying):
                let detail = underlying.localizedDescription
                if detail.isEmpty || detail.contains("error 0") {
                    return "I didnt get a reply from Gemini. Give it a minute and try again."
                }
                return "Gemini broke down: \(detail)"
            case .promptBlocked:
                return "I can't help with that message."
            case .responseStoppedEarly:
                return "I started replying but didnt finish."
            @unknown default:
                return "Something unexpected happened with Gemini. Try again later."
            }
        }

        return "Couldnt reach Gemini right now. Check your connection or switch to Apple FM."
    }
}

@MainActor
final class GeminiChatProvider {
    private let chat: Chat

    init() {
        let ai = FirebaseAI.firebaseAI(backend: .googleAI())
        let model = ai.generativeModel(modelName: "gemini-2.5-flash")
        chat = model.startChat()
    }

    func reply(to userMessage: String) async throws -> String {
        do {
            let response = try await chat.sendMessage(userMessage)
            return response.text ?? ""
        } catch {
            throw NSError( // error for when the ai fails to reply
                domain: "GeminiChatProvider",
                code: 1, // error code
                userInfo: [NSLocalizedDescriptionKey: GeminiErrorFormatter.message(for: error)] // error message
            )
        }
    }
}
