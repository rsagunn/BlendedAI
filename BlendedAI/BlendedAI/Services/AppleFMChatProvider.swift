//
//  AppleFMChatProvider.swift
//  BlendedAI
//

import FoundationModels
import Foundation

enum AppleFMError: LocalizedError {
    case modelUnavailable
    case generationFailed(String)

    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            "Apple Intelligence isn't available on this device. Turn it on in Settings, or switch to Gemini."
        case .generationFailed(let detail):
            if detail.lowercased().contains("operation couldn’t be completed") || detail.contains("error -1") {
                "Apple Intelligence could not generate that reply on this device. Try again on a supported device or switch to Gemini."
            } else {
                "Apple Intelligence could not generate a reply right now. \(detail)"
            }
        }
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

        do {
            let response = try await session!.respond(to: userMessage)
            return response.content
        } catch let error as LanguageModelSession.GenerationError {
            throw AppleFMError.generationFailed(error.localizedDescription)
        } catch {
            throw AppleFMError.generationFailed(error.localizedDescription)
        }
    }

    private static func transcript(from messages: [ChatMessage]) -> Transcript? {
        var entries: [Transcript.Entry] = []

        for message in messages {
            let segments = [Transcript.Segment.text(Transcript.TextSegment(content: message.text))]

            switch message.role {
            case .user:
                entries.append(.prompt(Transcript.Prompt(segments: segments)))
            case .assistant:
                entries.append(.response(Transcript.Response(assetIDs: [], segments: segments)))
            }
        }

        guard !entries.isEmpty else { return nil }
        return Transcript(entries: entries)
    }
}
