//
//  ChatListStore.swift
//  BlendedAI
//

import Foundation

@Observable
@MainActor
final class ChatListStore {
    private(set) var sessions: [ChatSession] = [] // other files can access but only read
    private(set) var currentSessionID: UUID

    var currentSession: ChatSession? {
        sessions.first { $0.id == currentSessionID }
    }

    init() {
        if let saved = Self.loadFromDisk() { // load previous saved chats
            sessions = saved.sessions
            currentSessionID = saved.currentSessionID
        } else { // create new chat
            let session = ChatSession()
            sessions = [session]
            currentSessionID = session.id
            saveToDisk()
        }
    }

    func createNewChat(provider: AIProvider = .gemini) {
        let session = ChatSession(provider: provider) // crreate new chat with specific ai 
        sessions.insert(session, at: 0) // begin at 0
        currentSessionID = session.id
        saveToDisk()
    }

    func selectSession(_ id: UUID) { // switching chats by its UUID
        guard sessions.contains(where: { $0.id == id }) else { return } // if the chat doesnt exist then exit
        currentSessionID = id
        saveToDisk()
    }

    func updateCurrentSession(messages: [ChatMessage], provider: AIProvider) { // update session with new messages and ai info
        guard let index = sessions.firstIndex(where: { $0.id == currentSessionID }) else { return } // find index

        var session = sessions[index] // update this info to "now"
        session.messages = messages
        session.provider = provider
        session.updatedAt = .now

        if let firstUserMessage = messages.first(where: { $0.role == .user }) { // first user message
            let trimmed = firstUserMessage.text.trimmingCharacters(in: .whitespacesAndNewlines) // trim whitespace
            if !trimmed.isEmpty { // if not empty then use first 40 for title
                session.title = String(trimmed.prefix(40))
            }
        }

        sessions[index] = session // replace old session with updaetd one
        sessions.sort { $0.updatedAt > $1.updatedAt } // oraganize session by newwest one
        saveToDisk()
    }

    private struct SavedState: Codable {
        var sessions: [ChatSession]
        var currentSessionID: UUID
    }

    private static var saveURL: URL { // convert session and session id to JSON
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent("chat_sessions.json")
    }

    private func saveToDisk() { // encode to json
        let state = SavedState(sessions: sessions, currentSessionID: currentSessionID)
        guard let data = try? JSONEncoder().encode(state) else { return }
        try? data.write(to: Self.saveURL, options: .atomic) // atomic write prevents corruption
    }

    private static func loadFromDisk() -> SavedState? { // load chats
        guard let data = try? Data(contentsOf: saveURL) else { return nil }
        return try? JSONDecoder().decode(SavedState.self, from: data)
    }
}
