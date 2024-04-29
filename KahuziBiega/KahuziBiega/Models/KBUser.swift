//
//  KBUser.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 28/04/2024.
//

import Foundation


struct KBUserData: Decodable {
    let token: String
    let data: KBUser
}

struct KBUser: Codable {
    var username: String
    var firstName: String
    var lastName: String
    var email: String
    var phoneNumber: String?
    var badgeNumber: String
    var role: KBUserRole
    
    enum KBUserRole: String, Codable {
        case User, Admin, SuperAdmin
    }
}

extension KBUser {
    static let example = KBUser(
        username: "john_doe",
        firstName: "John",
        lastName: "Doe",
        email: "john.doe@example.com",
        phoneNumber: "1234567890",
        badgeNumber: "A1234",
        role: .User
    )
}
