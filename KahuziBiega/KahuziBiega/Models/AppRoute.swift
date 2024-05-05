//
//  AppRoute.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 05/05/2024.
//

import Foundation

enum AppRoute: RawRepresentable, Hashable {
    // Define the raw value type for the enum
    typealias RawValue = String
    
    case signUp
    case signIn
    case verification(user: KBUser)
    case content
    
    // Implement the rawValue property
    var rawValue: RawValue {
        switch self {
        case .signUp:
            return "signup"
        case .signIn:
            return "signin"
        case .verification(let user):
            return "verification-\(String(describing: user.stringify()))"
        case .content:
            return "content"
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
               // Extracting the username from the rawValue
               let stringUser = String(rawValue.dropFirst("verification-".count))
               let user = KBUser.object(from: stringUser)
               if let user {
                   self = .verification(user: user)
               } else {
                   return nil
               }
           case "content":
               self = .content
           default:
               return nil
           }
       }
}
