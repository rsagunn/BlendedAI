//
//  ChatProviderHolder.swift
//  BlendedAI
//

import Foundation

@MainActor
final class ChatProviderHolder {
    let gemini = GeminiChatProvider()
    let apple = AppleFMChatProvider()

    func fetchReply(for provider: AIProvider) -> @Sendable (String) async throws -> String {
        switch provider {
        case .gemini:
            let gemini = gemini
            return { try await gemini.reply(to: $0) }
        case .apple:
            let apple = apple
            return { try await apple.reply(to: $0) }
        }
    }
}
