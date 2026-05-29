//
//  ChatView.swift
//  BlendedAI
//

import SwiftUI

struct ChatView: View {
    @State private var viewModel = ChatViewModel()

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    if viewModel.messages.isEmpty { // if no messages show empty state
                        emptyState
                    } else {
                        ForEach(viewModel.messages) { message in
                            ChatMessageRow(message: message)
                                .id(message.id) // for scrollTo
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .scrollDismissesKeyboard(.interactively) // dismiss keyboard when scrolling
            .onChange(of: viewModel.messages.count) { _, _ in // scroll to latest message
                scrollToLatest(using: proxy) // scroll to latest message
            }
        }
        .safeAreaInset(edge: .bottom) {
            ChatInputBar( // input bar for typing messages
                text: $viewModel.draftMessage, // what the user is typing
                canSend: viewModel.canSend, // true if user has typed something
                onSend: viewModel.send // send the message to the ai
            )
        }
        .navigationTitle("BlendedAI")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("Start a conversation")
                .font(.headline)
            Text("Type a message below.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    private func scrollToLatest(using proxy: ScrollViewProxy) { // scroll to latest message
        guard let lastID = viewModel.messages.last?.id else { return } // get the last message id
        withAnimation(.easeOut(duration: 0.2)) {
            proxy.scrollTo(lastID, anchor: .bottom) // scroll to the last message
        }
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
}
