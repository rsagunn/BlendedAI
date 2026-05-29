//
//  ChatMessage.swift
//  BlendedAI
//

import Foundation

// who is talking
// apple fm and gemini is assistant
enum ChatRole {
    case user
    case assistant
}

// a line
struct ChatMessage: Identifiable, Equatable {
    let id: UUID // an id for message
    let role: ChatRole // visibly marks whos talking
    let text: String // text
    let createdAt: Date // when msg created

    init(id: UUID = UUID(), role: ChatRole, text: String, createdAt: Date = .now) {
        self.id = id
        self.role = role
        self.text = text
        self.createdAt = createdAt
    }
}
