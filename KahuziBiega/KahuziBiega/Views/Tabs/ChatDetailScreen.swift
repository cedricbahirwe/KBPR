//
//  ChatDetailScreen.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 21/04/2024.
//

import SwiftUI
import Firebase

struct ChatDetailScreen: View {
    @ObservedObject var vm: ChatLogViewModel
    
    var body: some View {
        messagesView
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(vm.chatUser?.email ?? "")
                        .fontWeight(.medium)
                }
            }
            .onDisappear {
                vm.firestoreListener?.remove()
            }
    }
    
    static let emptyScrollToString = "Empty"

    private var messagesView: some View {
        ScrollView {
            ScrollViewReader { scrollViewProxy in
                VStack {
                    ForEach(vm.chatMessages) { message in
                        ChatBubbleView(message: message)
                    }
                    
                    HStack{ Spacer() }
                        .id(Self.emptyScrollToString)
                }
                .onReceive(vm.scrollUpdate) { numberOfItems in
                    print("trigger", numberOfItems)
                    if numberOfItems > 10 {
                        scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                    } else {
                        withAnimation(.easeOut(duration: 0.5)) {
                            scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                        }
                    }
                }
//                .onReceive(vm.$chatUser) { _ in
//                    print("Received")
//                    withAnimation(.easeOut(duration: 0.5)) {
//                        scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
//                    }
//                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            chatBottomBar
        }
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            Button(action: {}) {
                Image(systemName: "plus")
                    .bold()
            }
            
            TextField("", text: $vm.chatText, axis: .vertical)
                .textFieldStyle(.borderedStyle)
                .lineLimit(5)
            
            Button(action: {
                vm.sendMessage()
            }) {
                Image(systemName: "paperplane")
                    .resizable()
                    .symbolVariant(.circle.fill)
                    .frame(width: 30, height: 30)
                    
            }
            .disabled(!vm.canSendMessage)
        }
        .padding()
        .background(.ultraThickMaterial)
    }
}

#Preview {
    NavigationStack {
        ChatDetailScreen(vm: ChatLogViewModel(chatUser: nil))
    }
}


struct ChatBubbleView: View {
    let message: KBChatMessage
    private var isSender: Bool {
        message.fromId == KBFBManager.shared.auth.currentUser?.uid
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(message.cleanMessage)
                .foregroundStyle(.foreground)
            
            Text(message.timestamp, format: .dateTime.hour().minute())
                .font(.caption)
                .hidden()
        }
        .overlay(alignment: .bottomTrailing) {
            Text(message.timestampString)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(8)
        .background(
            isSender ? Color(.secondarySystemBackground) : Color.accent.opacity(0.5),
            in: .rect(cornerRadius: 12)
        )
        .padding(isSender ? .leading : .trailing, 50)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: isSender ? .trailing : .leading)
    }
}
