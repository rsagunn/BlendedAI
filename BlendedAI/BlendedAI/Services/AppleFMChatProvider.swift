//
//  AppleFMChatProvider.swift
//  BlendedAI
//

import FoundationModels
import Foundation
import Playgrounds // testing

enum AppleFMError: LocalizedError {
    case modelUnavailable(String) // error for when the model is not available

    var errorDescription: String? { // description of the error
        switch self {
        case .modelUnavailable(let reason):
            "Apple Intelligence is not available: \(reason)" // error message
        }
    }
}

@MainActor
final class AppleFMChatProvider {
    private let session: LanguageModelSession // session with the ai

    init() {
        session = LanguageModelSession(
            instructions: "You are a helpful assistant. Be concise." // instructions for the ai
        )
    }

    func reply(to userMessage: String) async throws -> String {
        switch SystemLanguageModel.default.availability { // check if the model is available
        case .available:
            break
        case .unavailable(let reason):
            throw AppleFMError.modelUnavailable(String(describing: reason)) // throw error if the model is not available
        }

        let response = try await session.respond(to: userMessage) // send the message to the ai
        return response.content // return the response from the ai
    }
}

#Playground {
    let provider = await AppleFMChatProvider()
    
    do {
        let reply = try await provider.reply(to: "Why is the sky blue?")
        print("AI Response: \(reply)")
    } catch let error as LanguageModelSession.GenerationError {	
        print("Detailed Framework Error: \(error)")
    } catch {
        print("General Error: \(error.localizedDescription)")
    }
}
