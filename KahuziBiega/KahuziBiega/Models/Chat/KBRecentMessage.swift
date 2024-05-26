//
//  KBRecentMessage.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 25/05/2024.
//

import Foundation
import FirebaseFirestore

struct KBRecentMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let text, email: String
    let fromId, toId: String
    let profilePic: String
    let timestamp: Date
    let kbId: String?
    
    var username: String {
        email.components(separatedBy: "@").first ?? email
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
