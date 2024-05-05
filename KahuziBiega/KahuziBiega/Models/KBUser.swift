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
    var status: KBAccountStatus
    
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
        print("The js is", jsonString)
        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        
        if let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]{
            print("Response JSON:", jsonObject)
        } else {
            print("Failed to parse JSON")
        }
        
        let decoder = KBDecoder()
        do {
            let object = try decoder.decode(KBUser.self, from: jsonData)
            return object
        } catch {
            print("Error decoding User to object: \(error)")
            return nil
        }
    }
}
