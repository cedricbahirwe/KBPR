//
//  Networking.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 28/04/2024.
//

import Foundation


import Foundation

final class NetworkClient: NSObject {
    private let baseURL = URL(string: "https://ac4b-102-22-141-31.ngrok-free.app")!
    private static let defaultToken = """
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjU4ZTY0OTI4LWI3N2MtNDUxNy05YTllLWRlODcyMjdhZjIwOSIsImVtYWlsIjoiZHJpb3NtYW4iLCJ0aW1lIjoxNzE1NjcwNTA2NTA1LCJleHAiOjE3MTU2OTkzMDYsImlhdCI6MTcxNTY3MDUwNiwibmJmIjoxNzE1NjcwNTA2fQ.0nQW7HxZkGBBwR7jR_MIy61FD-UkaVrPkB5cTcoeGd4
"""
    private var authorizationHeader: String {
        LocalStorage.getString(.userToken) ??
        NetworkClient.defaultToken
    }
    
    static let shared = NetworkClient()
    
    private override init() { }
    
    enum HTTPMethod: String {
        case get, post, put
        var name: String {
            rawValue.uppercased()
        }
    }
    enum Endpoint {
        case getUsers
        case getIncidents
        
        case allUsers
        
        case register
        case login
        case getuser(id: UUID)
        
        case updateStatus(user: KBUser.ID)
        
        var path: String {
            switch self {
            case .getUsers, .allUsers:
                "/api/users"
            case .getIncidents:
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
            case .login, .register:
                return .post
            case .getUsers, .getIncidents,
                    .getuser, .allUsers: return .get
            }
        }
    }
    
 
    private func buildRequestFor(_ endpoint: Endpoint) throws -> URLRequest {
        // Construct the request URL
        guard let url = URL(string: endpoint.path, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.addValue("Bearer \(authorizationHeader)", forHTTPHeaderField: "Authorization")
        request.httpMethod = endpoint.method.name
        return request
    }
    
    func post<D: Encodable, R: Decodable>(_ endpoint: Endpoint, content: D) async throws -> R {
        let  request = try buildRequestFor(endpoint)

        
        let encodedData = try JSONEncoder().encode(content)
        // Perform the request
        do {
            print("Start Upload")
            let (data, response) = try await URLSession.shared.upload(
                for: request,
                from: encodedData,
                delegate: self
            )
            
            print("Finish Upload")
            
            guard let response = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("Received", response.statusCode)
            
            try decodeResponse(response: response)
            
            
//            try debugResponse(data)
                        
            do {
                return try KBDecoder().decode(R.self, from: data)
            } catch {
                throw APIError.unableToDecodeResponse(error)
            }
        } catch {
            print("POST Error:", error.localizedDescription)
            throw APIError.requestFailed(error)
        }
    }
    
    func put<D: Encodable, R: Decodable>(_ endpoint: Endpoint, content: D) async throws -> R {
        let  request = try buildRequestFor(endpoint)

        
        let encodedData = try JSONEncoder().encode(content)
        // Perform the request
        do {
            print("Start Update")
            let (data, response) = try await URLSession.shared.upload(
                for: request,
                from: encodedData,
                delegate: self
            )
            
            print("Finish Update")
            
            guard let response = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("Received", response.statusCode)
            
            try decodeResponse(response: response)
            
            
//            try debugResponse(data)
                        
            do {
                return try KBDecoder().decode(R.self, from: data)
            } catch {
                throw APIError.unableToDecodeResponse(error)
            }
        } catch {
            print("POST Error:", error.localizedDescription)
            throw APIError.requestFailed(error)
        }
    }
    
    func get<R: Decodable>(_ endpoint: Endpoint) async throws -> R {
        let  request = try buildRequestFor(endpoint)
        
        // Perform the request
        do {
            print("Start Getting")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let response = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("Start finish getting")
            try decodeResponse(response: response)
            
            let decoder = KBDecoder()
            
            let users = try decoder.decode(R.self, from: data)
            return users
        } catch {
            throw APIError.requestFailed(error)
        }
    }
    
    private func debugResponse(_ data: Data) throws {
        if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
            print("Response JSON:", jsonObject)
        } else {
            print("Failed to parse JSON: ", String(data: data, encoding: .utf8) as Any)
        }
    }
    
    func decodeResponse(response: HTTPURLResponse) throws {
        let statusCode = response.statusCode
        if statusCode == 401 {
            print("Got here", LocalStorage.getString(.userToken))
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .unauthorizedRequest, object: nil)
            }
            return
        }
        
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
        self.dateDecodingStrategy = .formatted(LocalDecoder.dateFormatter)
//        self.dataDecodingStrategy = .
//        self.dateDecodingStrategy = .iso8601
    }
    
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensures consistent date parsing regardless of device's locale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC timezone
        return dateFormatter
    }()
}

extension NetworkClient: URLSessionTaskDelegate {
    
}

// TODO: Customize Error Messages
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

extension NSNotification.Name {
    static let unauthorizedRequest: NSNotification.Name = NSNotification.Name(rawValue: "unauthorizedRequest")
}
