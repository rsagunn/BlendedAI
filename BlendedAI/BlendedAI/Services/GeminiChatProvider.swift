//
//  GeminiChatProvider.swift
//  BlendedAI
//

import FirebaseAILogic

@MainActor
final class GeminiChatProvider {
    private let chat: Chat

    init() {
        let ai = FirebaseAI.firebaseAI(backend: .googleAI())
        let model = ai.generativeModel(modelName: "gemini-2.5-flash")
        chat = model.startChat()
    }

    func reply(to userMessage: String) async throws -> String {
        let response = try await chat.sendMessage(userMessage)
        return response.text ?? ""
    }
}
