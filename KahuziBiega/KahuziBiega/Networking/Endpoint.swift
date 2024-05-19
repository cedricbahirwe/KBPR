//
//  Endpoint.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 16/05/2024.
//

import Foundation

enum Endpoint {
    case getUsers
    
    case allUsers
    
    
    case register
    case login
    case getuser(id: UUID)
    
    case updateStatus(user: KBUser.ID)
    
    // MARK: - Incidents:
    case allIncidents
    case newIncident

    
    var path: String {
        switch self {
        case .getUsers, .allUsers:
            "/api/users"
        case .allIncidents, .newIncident:
            "/api/incidents"
        case .register:
            "/api/register"
        case .login:
            "/api/login"
        case .getuser(let id):
            "/api/users/\(id)"
        case .updateStatus(let userID):
            "/api/users/\(userID)/status"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .updateStatus:
            return .put
        case .login, .register, .newIncident:
            return .post
        case .getUsers, .allIncidents,
                .getuser, .allUsers: return .get
        }
    }
}
