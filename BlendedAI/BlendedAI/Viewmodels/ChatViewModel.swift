//
//  ChatViewModel.swift
//  BlendedAI
//

import Foundation // apple fm

enum ChatError: LocalizedError { // error for when the ai provider is not configured
    case providerNotConfigured

    var errorDescription: String? { // description of the error
        switch self {
        case .providerNotConfigured:
            "AI provider not connected yet" // error message
        }
    }
}

@Observable
@MainActor
final class ChatViewModel {
    private(set) var messages: [ChatMessage] = [] // all messages in the chat
    var draftMessage = "" // what the user is typing
    private(set) var isLoading = false // true if the ai is loading

    private let fetchReply: @Sendable (String) async throws -> String // fetch the reply from the ai (async keeps running in bg and throws an error

    var canSend: Bool { // true if user has typed something
        !draftMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty // true if the text is not empty
    init(fetchReply: @escaping @Sendable (String) async throws -> String = { _ in // initialize the view model
        throw ChatError.providerNotConfigured
    }) {
        self.fetchReply = fetchReply // set the fetch reply function
    }

    var canSend: Bool {
        !isLoading && !draftMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty // true if the user can send a message
    }

    func send() { // send the message to the ai
        Task { await sendMessage() }
    }

    private func sendMessage() async {
        let text = draftMessage.trimmingCharacters(in: .whitespacesAndNewlines) // get the text and remove whitespace and newlines
        guard !text.isEmpty, !isLoading else { return } // true if the message is not empty and the ai is not loading

        messages.append(ChatMessage(role: .user, text: text)) // add the message to messages
        draftMessage = "" // clear the draft message

        isLoading = true // set the loading state to true
        defer { isLoading = false } // set the loading state to false after the task is complete

        do {
            let reply = try await fetchReply(text) // fetch the reply from the ai
            messages.append(ChatMessage(role: .assistant, text: reply)) // add the reply to messages
        } catch {
            messages.append(ChatMessage(role: .assistant, text: error.localizedDescription)) // add the error to the messages array
        }
    }
}
