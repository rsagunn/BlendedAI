//
//  ChatInputBar.swift
//  BlendedAI
//

import SwiftUI

struct ChatInputBar: View {
    @Binding var text: String // what the user is typing
    let canSend: Bool // true if user has typed something
    var isLoading: Bool = false // true while waiting for ai reply
    let onSend: () -> Void // send the message to the ai

    @FocusState private var isFocused: Bool // true if the text field is focused

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            TextField("Message", text: $text, axis: .vertical)
                .lineLimit(1...6) // grows up to 6 lines
                .textFieldStyle(.plain)
                .focused($isFocused)
                .disabled(isLoading)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .submitLabel(.send)
                .onSubmit(sendIfPossible)

            Button(action: sendIfPossible) { // send the message to the ai
                if isLoading {
                    ProgressView()
                        .frame(width: 34, height: 34)
                } else {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 34))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(canSend ? Color.accentColor : Color.secondary)
                }
            }
            .buttonStyle(.plain)
            .disabled(!canSend) // disable button if user has not typed anything
            .accessibilityLabel("Send message") 
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
    }

    private func sendIfPossible() {
        guard canSend else { return } // if user has not typed anything dont send the message
        onSend() // send the message to the ai
        isFocused = true // keep keyboard open after send
    }
}

#Preview {
    @Previewable @State var text = "" // what the user is typing
    ChatInputBar(text: $text, canSend: !text.isEmpty, onSend: {}) // send the message to the ai
}
