//
//  ChatListStore.swift
//  BlendedAI
//

import Foundation

@Observable
@MainActor
final class ChatListStore {
    private(set) var sessions: [ChatSession] = []
    private(set) var currentSessionID: UUID

    var currentSession: ChatSession? {
        sessions.first { $0.id == currentSessionID }
    }

    init() {
        if let saved = Self.loadFromDisk() {
            sessions = saved.sessions
            currentSessionID = saved.currentSessionID
        } else {
            let session = ChatSession()
            sessions = [session]
            currentSessionID = session.id
            saveToDisk()
        }
    }

    func createNewChat(provider: AIProvider = .gemini) {
        let session = ChatSession(provider: provider)
        sessions.insert(session, at: 0)
        currentSessionID = session.id
        saveToDisk()
    }

    func selectSession(_ id: UUID) {
        guard sessions.contains(where: { $0.id == id }) else { return }
        currentSessionID = id
        saveToDisk()
    }

    func updateCurrentSession(messages: [ChatMessage], provider: AIProvider) {
        guard let index = sessions.firstIndex(where: { $0.id == currentSessionID }) else { return }

        var session = sessions[index]
        session.messages = messages
        session.provider = provider
        session.updatedAt = .now

        if let firstUserMessage = messages.first(where: { $0.role == .user }) {
            let trimmed = firstUserMessage.text.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                session.title = String(trimmed.prefix(40))
            }
        }

        sessions[index] = session
        sessions.sort { $0.updatedAt > $1.updatedAt }
        saveToDisk()
    }

    // MARK: - Persistence

    private struct SavedState: Codable {
        var sessions: [ChatSession]
        var currentSessionID: UUID
    }

    private static var saveURL: URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent("chat_sessions.json")
    }

    private func saveToDisk() {
        let state = SavedState(sessions: sessions, currentSessionID: currentSessionID)
        guard let data = try? JSONEncoder().encode(state) else { return }
        try? data.write(to: Self.saveURL, options: .atomic)
    }

    private static func loadFromDisk() -> SavedState? {
        guard let data = try? Data(contentsOf: saveURL) else { return nil }
        return try? JSONDecoder().decode(SavedState.self, from: data)
    }
}
