//
//  Networking.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 28/04/2024.
//

import Foundation


import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case invalidData
}

class NetworkClient {
    
    let baseURL = URL(string: "https://e8e0-102-22-141-31.ngrok-free.app")!
    let authorizationHeader = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjJkZTg4ZjE3LWQ4NzItNDllMS05MDUyLWIzZWM5YjFiMzdkMSIsInVzZXJuYW1lIjoiZHJpb3NtYW4iLCJ0aW1lIjoxNzE0Mzc3NjUxMjg0LCJleHAiOjE3MTQ0MDY0NTEsImlhdCI6MTcxNDM3NzY1MSwibmJmIjoxNzE0Mzc3NjUxfQ.nIZgYsZ7n3pWC6Cu6AdekauBoScn1p2am7RIzhChTwc"
    
    static let shared = NetworkClient()
    
    enum HTTPMethod {
        case get, post
    }
    enum Endpoint {
        case getUsers
        case getIncidents
        
        var path: String {
            switch self {
            case .getUsers:
                "/api/users"
            case .getIncidents:
                "/api/incidents"
            }
        }
        
        var method: HTTPMethod {
            return .get
        }
    }
    
    func getUserData() async throws -> [KBUser] {
        try await get(.getUsers)
    }
    
    func get<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        // Construct the request URL
        guard let url = URL(string: endpoint.path, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.addValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        
        // Perform the request
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
//            try debugResponse(data)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601  // <-- here

            let users = try decoder.decode(T.self, from: data)
            return users
        } catch {
            throw APIError.requestFailed(error)
        }
        
    }
    
    private func debugResponse(_ data: Data) throws {
        if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any] ]{
            print("Response JSON:", jsonObject)
        } else {
            print("Failed to parse JSON")
        }
    }
}

