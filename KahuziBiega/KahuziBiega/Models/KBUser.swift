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
    var profilePic: String?
    
    
    // Computed
    
    var fullName: String { firstName + " " + lastName }
    
    enum KBUserRole: String, Codable, CaseIterable, Comparable {
        static func < (lhs: KBUser.KBUserRole, rhs: KBUser.KBUserRole) -> Bool {
            // Best Approach is to use switch, but I'm using rawValue for demo purpose
            lhs.rawValue.count < rhs.rawValue.count
        }
        
        case User, Admin, SuperAdmin
    }
    
    enum KBAccountStatus: String, CaseIterable, Codable {
        case Pending, Approved, Suspended, Banned
    }
    
    var usernameFormatted: String {
        "@\(username)"
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
        status: .Pending,
        createdAt: .now
    )
    
    static let admin = KBUser(
        id: UUID(),
        username: "driosman",
        firstName: "Drios",
        lastName: "Man",
        email: "drios.man@example.com",
        phoneNumber: "099018009812",
        badgeNumber: "AD002",
        role: .SuperAdmin,
        status: .Approved,
        createdAt: .now
    )
}

extension KBUser {
    static func object(from userID: KBUser.ID) -> KBUser? {
        LocalStorage.getAUser(for: userID)
    }
}
