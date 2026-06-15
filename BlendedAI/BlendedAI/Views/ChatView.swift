//
//  ChatView.swift
//  BlendedAI
//

import SwiftUI

struct ChatView: View {
    let chatList: ChatListStore
    private let providerHolder: ChatProviderHolder

    @State private var provider: AIProvider = .gemini
    @State private var viewModel: ChatViewModel
    @State private var showChatList = false

    init(chatList: ChatListStore) {
        self.chatList = chatList
        let holder = ChatProviderHolder()
        providerHolder = holder
        let session = chatList.currentSession
        let provider = session?.provider ?? .gemini
        let messages = session?.messages ?? []
        holder.prepareForSession(provider: provider, messages: messages)
        _provider = State(initialValue: provider)
        _viewModel = State(
            initialValue: ChatViewModel(
                messages: messages,
                fetchReply: holder.fetchReply(for: provider)
            )
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
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.messages.count) { _, _ in
                scrollToLatest(using: proxy)
            }
        }
        .safeAreaInset(edge: .bottom) {
            ChatInputBar(
                text: $viewModel.draftMessage,
                canSend: viewModel.canSend,
                isLoading: viewModel.isLoading,
                onSend: viewModel.send
            )
        }
        .navigationTitle("BlendedAI")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showChatList = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Open chats")
            }

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
        .sheet(isPresented: $showChatList) {
            NavigationStack {
                ChatListView(
                    chatList: chatList,
                    currentProvider: provider,
                    onNewChat: loadCurrentSession,
                    onSelectChat: loadCurrentSession
                )
            }
        }
        .onChange(of: viewModel.messages) { _, newMessages in
            chatList.updateCurrentSession(messages: newMessages, provider: provider)
        }
        .onChange(of: provider) { _, newProvider in
            let messages = viewModel.messages
            providerHolder.prepareForSession(provider: newProvider, messages: messages)
            viewModel = ChatViewModel(
                messages: messages,
                fetchReply: providerHolder.fetchReply(for: newProvider)
            )
            chatList.updateCurrentSession(messages: messages, provider: newProvider)
        }
        .onChange(of: chatList.currentSessionID) { _, _ in
            loadCurrentSession()
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

    private func loadCurrentSession() {
        guard let session = chatList.currentSession else { return }
        providerHolder.prepareForSession(provider: session.provider, messages: session.messages)
        provider = session.provider
        viewModel = ChatViewModel(
            messages: session.messages,
            fetchReply: providerHolder.fetchReply(for: session.provider)
        )
    }

    private func scrollToLatest(using proxy: ScrollViewProxy) {
        guard let lastID = viewModel.messages.last?.id else { return }
        withAnimation(.easeOut(duration: 0.2)) {
            proxy.scrollTo(lastID, anchor: .bottom)
        }
    }
}

#Preview {
    NavigationStack {
        ChatView(chatList: ChatListStore())
    }
}
