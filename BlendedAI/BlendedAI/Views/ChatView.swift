//
//  ChatView.swift
//  BlendedAI
//

import SwiftUI

struct ChatView: View {
    private let providerHolder: ChatProviderHolder

    @State private var provider: AIProvider = .gemini
    @State private var viewModel: ChatViewModel

    init() {
        let holder = ChatProviderHolder()
        providerHolder = holder
        _viewModel = State(
            initialValue: ChatViewModel(fetchReply: holder.fetchReply(for: .gemini))
        )
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    if viewModel.messages.isEmpty {
                        emptyState
                    } else {
                        ForEach(viewModel.messages) { message in
                            ChatMessageRow(message: message)
                                .id(message.id)
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
                isLoading: viewModel.isLoading, // true while waiting for AI reply
                onSend: viewModel.send // send the message to the ai
            )
        }
        .navigationTitle("BlendedAI")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("AI Provider", selection: $provider) {
                    ForEach(AIProvider.allCases) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 200)
                .disabled(viewModel.isLoading)
            }
        }
        .onChange(of: provider) { _, newProvider in
            viewModel = ChatViewModel(fetchReply: providerHolder.fetchReply(for: newProvider))
        }
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
                .multilineTextAlignment(.center)
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
