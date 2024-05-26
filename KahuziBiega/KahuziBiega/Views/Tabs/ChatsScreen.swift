//
//  ChatsScreen.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 21/04/2024.
//

import SwiftUI

struct ChatsScreen: View {
    @ObservedObject private var vm = MainMessagesViewModel()
    private var chatLogViewModel = ChatLogViewModel(chatUser: nil)
    @State private var shouldNavigateToChatLogView = false
    @State private var shouldShowNewMessageScreen = false

    var body: some View {
        NavigationStack {
            messagesView
            .safeAreaInset(edge: .top) {
                HStack {
                    Text("Conversations")
                        .font(.title.bold())
                    Spacer()
                    
                    Button(action: {
                        shouldShowNewMessageScreen.toggle()
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .symbolVariant(.circle.fill)
                            .frame(width: 26, height: 26)
                    }
                }
                .padding()
                .background(.ultraThinMaterial, ignoresSafeAreaEdges: .top)
            }
            .toolbar(.hidden, for: .navigationBar)
            .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
                CreateNewMessageView(didSelectNewUser: { user in
                    self.chatLogViewModel.chatUser = user
                    self.chatLogViewModel.fetchMessages()
                    self.shouldNavigateToChatLogView.toggle()
                })
            }
            .navigationDestination(isPresented: $shouldNavigateToChatLogView) {
                ChatLogView(vm: chatLogViewModel)
            }
        }
    }
    
    private var messagesView: some View {
        ScrollView {
            ForEach(vm.recentMessages) { recentMessage in
                VStack {
                    Button {
                        let uid = KBFBManager.shared.auth.currentUser?.uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId
                        
                        let chatUser = KBChatUser(id: uid, uid: uid, email: recentMessage.email, profilePic: recentMessage.profilePic, kbId: recentMessage.kbId)
                        
                        self.chatLogViewModel.chatUser = chatUser
                        self.chatLogViewModel.fetchMessages()
                        self.shouldNavigateToChatLogView.toggle()
                    } label: {
                        ChatPreviewRowView(preview: recentMessage)
                            .contentShape(.rect)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Divider()
                        .padding(.vertical, 6)
                    
                }
                .padding(.horizontal)
                
            }
            .padding(.bottom, 50)
        }
    }
}

#Preview {
    NavigationStack {
        ChatsScreen()
    }
}

struct ChatPreviewRowView: View {
    private let primaryRed = Color(red: 216/255, green: 77/255, blue: 77/255)
    let preview: KBRecentMessage
    
    private var tintColor: Color {
        KBFBManager.shared.auth.currentUser?.uid == preview.fromId ? .secondary : .accentColor
    }
    var body: some View {
        HStack(spacing: 12) {
            KBImage(preview.profilePic)
                .frame(width: 48, height: 48)
                .cornerRadius(24)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(preview.username)
                        .font(.headline.weight(.medium))
                    
                    Spacer()
                    
                    Text(preview.timeAgo)
                        .font(.caption)
                        .foregroundStyle(tintColor)
                }
                
                Text(preview.text.trimmingCharacters(in: .whitespacesAndNewlines))
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
        }
    }
}

//extension String {
//    var abbreviation: String {
//        let words = self.components(separatedBy: " ")
//        let abbreviation = words.map { $0.prefix(1) }
//        return abbreviation.joined().uppercased()
//    }
//}

