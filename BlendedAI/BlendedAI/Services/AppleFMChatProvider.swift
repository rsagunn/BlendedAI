//
//  AppleFMChatProvider.swift
//  BlendedAI
//

import FoundationModels
import Foundation

enum AppleFMError: LocalizedError {
    case modelUnavailable

    var errorDescription: String? {
        "Apple Intelligence isn't available on this device. Turn it on in Settings, or switch to Gemini."
    }
}

@MainActor
final class AppleFMChatProvider {
    private var session: LanguageModelSession? // session with the ai

    private func sessionOrCreate() -> LanguageModelSession {
        if let session { return session }
        let session = LanguageModelSession(
            instructions: "You are a helpful assistant. Be concise."
        )
        self.session = session
        return session
    }

    func reply(to userMessage: String) async throws -> String {
        switch SystemLanguageModel.default.availability { // check if the model is available
        case .available:
            break
        case .unavailable:
            throw AppleFMError.modelUnavailable
        }

        let response = try await sessionOrCreate().respond(to: userMessage)
        return response.content
    }
}
