//
//  ChatProviderHolder.swift
//  BlendedAI
//

import Foundation

@MainActor
final class ChatProviderHolder {
    private var gemini: GeminiChatProvider?
    private var apple: AppleFMChatProvider?

    func prepareForSession(provider: AIProvider, messages: [ChatMessage]) {
        switch provider {
        case .gemini:
            gemini = GeminiChatProvider(messages: messages)
        case .apple:
            let appleProvider = AppleFMChatProvider()
            appleProvider.configure(messages: messages)
            apple = appleProvider
        }
    }

    func fetchReply(for provider: AIProvider) -> @Sendable (String) async throws -> String {
        switch provider {
        case .gemini:
            guard let gemini else {
                return { _ in throw ChatError.providerNotConfigured }
            }
            return { try await gemini.reply(to: $0) }
        case .apple:
            guard let apple else {
                return { _ in throw ChatError.providerNotConfigured }
            }
            return { try await apple.reply(to: $0) }
        }
    }
}
