//
//  ChatSession.swift
//  BlendedAI
//

import Foundation

struct ChatSession: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var messages: [ChatMessage]
    var provider: AIProvider
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String = "New Chat",
        messages: [ChatMessage] = [],
        provider: AIProvider = .gemini,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.messages = messages
        self.provider = provider
        self.updatedAt = updatedAt
    }

    var preview: String {
        if let last = messages.last { // last message in the chat
            return last.text // return the text of the last message
        }
        return "No messages yet" // if no message return a default message
    }
}
