//
//  ChatProviderHolder.swift
//  BlendedAI
//

import Foundation

@MainActor
final class ChatProviderHolder {
    private var gemini: GeminiChatProvider?
    private var apple: AppleFMChatProvider?

    func fetchReply(for provider: AIProvider) -> @Sendable (String) async throws -> String {
        switch provider {
        case .gemini:
            let gemini = gemini ?? GeminiChatProvider()
            self.gemini = gemini
            return { try await gemini.reply(to: $0) }
        case .apple:
            let apple = apple ?? AppleFMChatProvider()
            self.apple = apple
            return { try await apple.reply(to: $0) }
        }
    }
}
