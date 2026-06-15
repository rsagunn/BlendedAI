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
    private var session: LanguageModelSession?

    private static let instructions = """
    You are a senior developer with 10 years of experience in all types of programming languages.
    Be concise and helpful. If you dont know the answer, say so.
    """

    func configure(messages: [ChatMessage]) {
        if messages.isEmpty {
            session = LanguageModelSession(instructions: Self.instructions)
        } else if let transcript = Self.transcript(from: messages) {
            session = LanguageModelSession(transcript: transcript)
        } else {
            session = LanguageModelSession(instructions: Self.instructions)
        }
    }

    func reply(to userMessage: String) async throws -> String {
        switch SystemLanguageModel.default.availability {
        case .available:
            break
        case .unavailable:
            throw AppleFMError.modelUnavailable
        }

        if session == nil {
            configure(messages: [])
        }

        let response = try await session!.respond(to: userMessage)
        return response.content
    }

    private static func transcript(from messages: [ChatMessage]) -> Transcript? {
        var entries: [Transcript.Entry] = []

        for message in messages {
            switch message.role {
            case .user:
                entries.append(.prompt(Prompt(message.text)))
            case .assistant:
                entries.append(.response(Response(message.text)))
            }
        }

        guard !entries.isEmpty else { return nil }
        return Transcript(entries: entries)
    }
}
