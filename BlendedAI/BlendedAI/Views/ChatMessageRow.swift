//
//  ChatMessageRow.swift
//  BlendedAI
//

import SwiftUI

struct ChatMessageRow: View {
    let message: ChatMessage

    private var isUser: Bool { message.role == .user } // true if the message is from the user

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 48) } // push user bubbles to the right

            Text(message.text)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(bubbleColor)
                .foregroundStyle(foregroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            if !isUser { Spacer(minLength: 48) } // push assistant bubbles to the left
        }
    }

    private var bubbleColor: Color {
        isUser ? Color.accentColor : Color(.secondarySystemBackground)
    }

    private var foregroundColor: Color {
        isUser ? .white : .primary
    }
}

#Preview {
    VStack(spacing: 12) {
        ChatMessageRow(message: ChatMessage(role: .user, text: "Whos Reilan")) // user message
        ChatMessageRow(message: ChatMessage(role: .assistant, text: "The goat")) // ai message
    }
    .padding()
}
