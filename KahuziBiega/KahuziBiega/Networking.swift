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
    
    case badRequest(Int)
    case serverError(Int)
    case unknowStatus(Int)
    
    case unableToDecodeResponse(Error)
    
    var message: String {
        switch self {
        case .unableToDecodeResponse(let error),
                .requestFailed(let error):
            return error.localizedDescription
        default: return localizedDescription
        }
    }
}

class NetworkClient {
    
    let baseURL = URL(string: "https://c004-102-22-141-31.ngrok-free.app")!
    let authorizationHeader = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImQ3Y2NjMGNhLTdlYWItNGU0My1iYzRmLTAxM2I3Y2JhZDI3YiIsInVzZXJuYW1lIjoiZHJpb3NtYW4iLCJ0aW1lIjoxNzE0OTEyODExNDk2LCJleHAiOjE3MTQ5NDE2MTEsImlhdCI6MTcxNDkxMjgxMSwibmJmIjoxNzE0OTEyODExfQ.Q78gLv_AVEx4iEbVNeUtD8cIgTjQ0Y38cn48pVvX91Q"
    
    static let shared = NetworkClient()
    
    private init() { }
    
    enum HTTPMethod: String {
        case get, post
        var name: String {
            rawValue.uppercased()
        }
    }
    enum Endpoint {
        case getUsers
        case getIncidents
        
        case register
        case login
        case getuser(id: UUID)
        
        var path: String {
            switch self {
            case .getUsers:
                "/api/users"
            case .getIncidents:
                "/api/incidents"
            case .register:
                "/api/register"
            case .login:
                "/api/login"
            case .getuser(let id):
                "/api/users/\(id)"
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .login, .register:
                return .post
            case .getUsers, .getIncidents,
                    .getuser: return .get
            }
        }
    }
    
    func getUserData() async throws -> [KBUser] {
        try await get(.getUsers)
    }
    
    private func makeRequestFor(_ endpoint: Endpoint) throws -> URLRequest {
        // Construct the request URL
        guard let url = URL(string: endpoint.path, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.addValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        request.httpMethod = endpoint.method.name
        return request
    }
    
    func post<D: Encodable, R: Decodable>(_ endpoint: Endpoint, content: D) async throws -> R {
        let  request = try makeRequestFor(endpoint)

        
        let encodedData = try JSONEncoder().encode(content)
        // Perform the request
        do {
            print("First")
            let (data, response) = try await URLSession.shared.upload(for: request, from: encodedData)
            
            
            guard let response = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            try decodeResponse(response: response)
            
            
            try debugResponse(data)
                        
            do {
                return try KBDecoder().decode(R.self, from: data)
            } catch {
                throw APIError.unableToDecodeResponse(error)
            }
        } catch {
            print("Error saying", error.localizedDescription)
            throw APIError.requestFailed(error)
        }
    }
    
    func get<R: Decodable>(_ endpoint: Endpoint) async throws -> R {
        let  request = try makeRequestFor(endpoint)
        
        // Perform the request
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
//            try debugResponse(data)
            
            let decoder = KBDecoder()
            
            let users = try decoder.decode(R.self, from: data)
            return users
        } catch {
            throw APIError.requestFailed(error)
        }
    }
    
    private func debugResponse(_ data: Data) throws {
        if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]{
            print("Response JSON:", jsonObject)
        } else {
            print("Failed to parse JSON")
        }
    }
    
    func decodeResponse(response: HTTPURLResponse) throws {
        let statusCode = response.statusCode
        
        switch statusCode {
        case 200...299:
            return
        case 400...499:
            throw APIError.badRequest(statusCode)
        case 500...599:
            throw APIError.serverError(statusCode)
        default:
            throw APIError.unknowStatus(statusCode)
        }
    }
}


struct ValidationError: Decodable, Error {
    let validation: String?
    let code: String
    let message: String
    let expected: String?
    let received: String?
}


class KBDecoder: JSONDecoder {
//    override var dataDecodingStrategy: JSONDecoder.DataDecodingStrategy
    
    override init() {
        super.init()
        // TODO: Fix Date formatting forever
        self.dateDecodingStrategy = .iso8601
    }
}
