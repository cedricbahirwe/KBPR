//
//  KBChatUser.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 25/05/2024.
//

import FirebaseFirestore

struct KBChatUser: Codable, Identifiable {
    @DocumentID var id: String?
    let uid, email, profilePic: String
    
    let firstName: String
    let lastName: String
    let username: String
    
    let kbId: String?
}
