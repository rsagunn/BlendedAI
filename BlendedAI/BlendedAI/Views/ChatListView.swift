//
//  ChatListView.swift
//  BlendedAI
//

import SwiftUI

struct ChatListView: View {
    @Environment(\.dismiss) private var dismiss

    let chatList: ChatListStore
    let currentProvider: AIProvider
    let onNewChat: () -> Void
    let onSelectChat: () -> Void

    var body: some View {
        List(chatList.sessions) { session in
            Button {
                chatList.selectSession(session.id)
                onSelectChat()
                dismiss()
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(session.title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Spacer()
                        Text(session.provider.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text(session.preview)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Text(session.updatedAt, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Chats")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    chatList.createNewChat(provider: currentProvider)
                    onNewChat()
                    dismiss()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New chat")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatListView(
            chatList: ChatListStore(),
            currentProvider: .gemini,
            onNewChat: {},
            onSelectChat: {}
        )
    }
}
