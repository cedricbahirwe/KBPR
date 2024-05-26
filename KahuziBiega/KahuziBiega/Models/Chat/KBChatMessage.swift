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
}
