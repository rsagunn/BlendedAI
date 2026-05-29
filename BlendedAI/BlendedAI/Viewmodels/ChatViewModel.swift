//
//  ChatViewModel.swift
//  BlendedAI
//

import Foundation // apple fm

@Observable
@MainActor
final class ChatViewModel {
    private(set) var messages: [ChatMessage] = [] // all messages in the chat
    var draftMessage = "" // what the user is typing

    var canSend: Bool { // true if user has typed something
        !draftMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty // true if the text is not empty
    }

    func send() { // send the message to the ai
        let text = draftMessage.trimmingCharacters(in: .whitespacesAndNewlines) // remove whitespace and newlines
        guard !text.isEmpty else { return } // if the text is empty dont send the message

        messages.append(ChatMessage(role: .user, text: text)) // add the users message to the list
        draftMessage = "" // clear the text field

        // ai reply will go here when a gemini is connected
    }
}
