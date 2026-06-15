//
//  ContentView.swift
//  BlendedAI
//
//  Created by Reilan Sagun on 2026-05-11.
//

import SwiftUI


struct ContentView: View {
    @State private var chatList = ChatListStore()

    var body: some View {
        NavigationStack {
            ChatView(chatList: chatList)
        }
    }
}

#Preview {
    ContentView()
}
