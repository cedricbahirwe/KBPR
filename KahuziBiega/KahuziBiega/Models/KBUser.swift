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

struct KBUser: Codable {
    var id: UUID
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
        id: UUID(),
        username: "john_doe",
        firstName: "John",
        lastName: "Doe",
        email: "john.doe@example.com",
        phoneNumber: "1234567890",
        badgeNumber: "A1234",
        role: .User
    )
}

extension KBUser: Stringifiable {
    func stringify() -> String? {
        let encoder = JSONEncoder()
//        encoder.outputFormatting = .prettyPrinted // Optional: for pretty printed JSON
        do {
            let jsonData = try encoder.encode(self)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Error encoding object to JSON: \(error)")
        }
        return nil
    }
    
    static func object(from jsonString: String) -> KBUser? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(KBUser.self, from: jsonData)
            return object
        } catch {
            print("Error decoding JSON to object: \(error)")
            return nil
        }
    }
}
