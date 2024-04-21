//
//  ChatDetailScreen.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 21/04/2024.
//

import SwiftUI

struct ChatDetailScreen: View {
    @State private var message = ""
    let preview: ChatPreview
    var body: some View {
        ScrollView {
            
            VStack(alignment: .leading, spacing: 16) {
                ChatBubbleView(
                    message: "Hi Samy, any progress on the task? We need an update for standup.",
                    isSender: false
                )
                
                ChatBubbleView(
                    message: "Hi Ibi!\nYes, I just finished reviewing the area, I’m drafting the final report.",
                    isSender: true
                )
                
                ChatBubbleView(
                    message: preview.subtitle,
                    isSender: true
                )
                
            }
            .frame(maxWidth: .infinity)
        }
        
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(preview.title)
                    .fontWeight(.medium)
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                }
                
                Button(action: {}) {
                    Image(systemName: "phone.fill")
                }
            }
        }
        
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 16) {
                Button(action: {}) {
                    Image(systemName: "plus")
                        .bold()
                }
                
                TextField("", text: $message, axis: .vertical)
                    .textFieldStyle(.borderedStyle)
                
                
                Button(action: {}) {
                    Image(systemName: "paperplane.fill")
                        .bold()
                }
                .disabled(message.isEmpty)
            }
            .padding()
            .background(.ultraThickMaterial)
        }
    }
}

#Preview {
    NavigationStack {
        ChatDetailScreen(preview: .examples[0])
    }
}


struct ChatBubbleView: View {
    let message: String
    let isSender: Bool
    var body: some View {
        Text(message)
            .foregroundStyle(isSender ? .accent : .white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
            .padding([.vertical, .trailing])
            .background {
                ZStack {
                    if isSender {
                        Image(.chatBubble)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(.secondary)
                    }
                    
                    Image(.chatBubble)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(isSender ? .white : .accent)
                        .scaleEffect(x: isSender ? 1 : 1.0, y: isSender ? 0.99 : 1.0, anchor: .center)
                }
                .scaleEffect(x: isSender ? -1 : 1 , y: 1, anchor: .center)

                    
            }
            .padding(isSender ? .leading : .trailing, 40)
            .frame(maxWidth: .infinity, alignment: isSender ? .trailing : .leading)
    }
}
