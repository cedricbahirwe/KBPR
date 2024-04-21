//
//  ChatsScreen.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 21/04/2024.
//

import SwiftUI

struct ChatsScreen: View {
    private let previews = ChatPreview.examples
    var body: some View {
        ScrollView {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .bold()
                
                TextField("Search", text: .constant(""))
                    .bold()
            }
            .padding(12)
            .background(Color.gray.opacity(0.1), in: .rect(cornerRadius: 5))
            .padding()
            
            ForEach(previews) { preview in
                NavigationLink {
                    ChatDetailScreen(preview: preview)
                } label: {
                    VStack(spacing: 5) {
                        ChatPreviewRowView(preview: preview)
                        if preview.id != previews.last?.id {
                            Divider()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .buttonStyle(PlainButtonStyle())
               
            }
            .padding(.horizontal)
            
            Spacer()
            
            
        }
        .safeAreaInset(edge: .top) {
            HStack {
                Text("Conversations")
                    .bold()
                Spacer()
                Button(action: {}) {
                    Image(.more)
                }
            }
            .padding()
            .background(.ultraThinMaterial, ignoresSafeAreaEdges: .top)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        ChatsScreen()
    }
}

struct ChatPreviewRowView: View {
    private let primaryRed = Color(red: 216/255, green: 77/255, blue: 77/255)
    let preview: ChatPreview
    var body: some View {
        HStack(spacing: 12) {
            Group {
                if let image = preview.image {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 48, height: 48)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundStyle(.accent)
                            .frame(width: 48, height: 48)
                        Text(preview.title.abbreviation)
                            .font(.callout.weight(.medium))
                            .foregroundStyle(.white)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(preview.title)
                        .font(.headline.weight(.medium))
                        
                    Spacer()
                    
                    Text(preview.dateAsString)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                }

                HStack {
                    Text(preview.subtitle)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Group {
                        if preview.onRead == 0 {
                            Image("checkmark")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .foregroundStyle(primaryRed)
                        } else {
                            Text("\(preview.onRead)")
                                .font(.callout.weight(.semibold))
                                .padding(8)
                                .background(primaryRed.quinary.opacity(0.3), in: .circle)
                        }
                    }
                    .foregroundStyle(primaryRed)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
          
        }
    }
}

struct ChatPreview: Identifiable {
    let id: UUID = UUID()
    var image: UIImage?
    var title: String
    var subtitle: String
    var dateAsString: AttributedString
    var onRead: Int
    
    static let examples = [
        ChatPreview(
            image: .img1,
            title: "Kasongo David",
            subtitle: "That’s great, I look forward to hearing ba...",
            dateAsString: "11:20 am",
            onRead: 1
        ),
        ChatPreview(
            image: nil,
            title: "East Area Management",
            subtitle: "@Ovo How is it going?",
            dateAsString: "11:11 am",
            onRead: 0
        ),
        ChatPreview(
            image: .img2,
            title: "Claude Bauma",
            subtitle: "Feedback Description.docx",
            dateAsString: "Yesterday",
            onRead: 1
        ),
        ChatPreview(
            image: .img3,
            title: "Ibi Sankara",
            subtitle: "How is it going?",
            dateAsString: "Yesterday",
            onRead: 0
        ),
        ChatPreview(
            image: .img4,
            title: "Alain Mugisho",
            subtitle: "Please drop your morning update.",
            dateAsString: "Yesterday",
            onRead: 1
        ),
        ChatPreview(
            image: .img5,
            title: "Busoke Akilimali",
            subtitle: "Aight, noted",
            dateAsString: "Yesterday",
            onRead: 1
        )
    ]
    
}

extension String {
    var abbreviation: String {
        let words = self.components(separatedBy: " ")
        let abbreviation = words.map { $0.prefix(1) }
        return abbreviation.joined().uppercased()
    }
}
