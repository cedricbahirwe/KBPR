//
//  KBUser.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 28/04/2024.
//

import Foundation


protocol Stringifiable {
    func stringify() -> String?
}

struct KBUserData: Decodable {
    let token: String
    let data: KBUser
}

struct KBUser: Identifiable, Codable {
    var id: UUID
    var username: String
    var firstName: String
    var lastName: String
    var email: String
    var phoneNumber: String?
    var badgeNumber: String
    var role: KBUserRole
    var status: KBAccountStatus
    
    var createdAt: Date
    
    
    // Computed
    
    var fullName: String { firstName + " " + lastName }
    
    enum KBUserRole: String, Codable {
        case User, Admin, SuperAdmin
    }
    
    enum KBAccountStatus: String, Codable {
        case Pending, Approved, Suspended, Banned
    }
}

extension KBUser {
    static let example = KBUser(
        id: UUID(),
        username: "john_doe",
        firstName: "John",
        lastName: "Doe",
        email: "john.doe@example.com",
        phoneNumber: "1234567890",
        badgeNumber: "A1234",
        role: .User,
        status: .Pending
    )
}

extension KBUser {
    static func object(from userID: KBUser.ID) -> KBUser? {
        LocalStorage.getAUser(for: userID)
    }
}
