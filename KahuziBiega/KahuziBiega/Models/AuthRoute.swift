//
//  AppRoute.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 05/05/2024.
//

import Foundation

enum AuthRoute: RawRepresentable, Hashable {
    // Define the raw value type for the enum
    typealias RawValue = String
    
    case signUp
    case signIn
    case verification(user: KBUser)
    
    // Implement the rawValue property
    var rawValue: RawValue {
        switch self {
        case .signUp:
            return "signup"
        case .signIn:
            return "signin"
        case .verification(let user):
            return "verification-\(user.id)"
        }
    }
    
    // Implement the initializer from raw value
    init?(rawValue: RawValue) {
        switch rawValue {
        case "signup":
            self = .signUp
        case "signin":
            self = .signIn
        case let rawValue where rawValue.hasPrefix("verification-"):
            if let stringUserID = UUID(uuidString: String(rawValue.dropFirst("verification-".count))),
               let user = KBUser.object(from: stringUserID) {
                self = .verification(user: user)
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}
