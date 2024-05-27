//
//  KBChatMessage.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 25/05/2024.
//

import Foundation
import FirebaseFirestore

struct KBChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let fromId, toId, text: String
    let timestamp: Date
    
    var cleanMessage: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var timestampString: String {
        if Date.now.timeIntervalSince(timestamp) > 86_400 {
            timestamp.timeAgo
        } else {
            timestamp.formatted(date: .omitted, time: .shortened)
        }
    }
}
