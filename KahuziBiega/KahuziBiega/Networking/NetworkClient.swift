//
//  NetworkClient.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 28/04/2024.
//

import Foundation

enum Constants {
    /// App URL: use ngrok http http://localhost:3000 to genrate when this one expires
    static let baseURL = URL(string: "https://2fdb-102-22-141-31.ngrok-free.app")!
    
//    static let staticToken: String = """
//    eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjU4ZTY0OTI4LWI3N2MtNDUxNy05YTllLWRlODcyMjdhZjIwOSIsImVtYWlsIjoiZHJpb3NtYW4iLCJ0aW1lIjoxNzE1NjcwNTA2NTA1LCJleHAiOjE3MTU2OTkzMDYsImlhdCI6MTcxNTY3MDUwNiwibmJmIjoxNzE1NjcwNTA2fQ.0nQW7HxZkGBBwR7jR_MIy61FD-UkaVrPkB5cTcoeGd4
//    """
    
    enum Pusher {
        static let appID = 962207
        static let key = "fd4d4731402adac340ad"
        static let secret = "fd97f4ac7fddf699759d"
        static let cluster = "ap2"
    }
}

final class NetworkClient: NSObject {
    static let shared = NetworkClient()
    
    private let baseURL = Constants.baseURL

    
    private override init() { }
    
    private func buildRequestFor(_ endpoint: Endpoint) throws -> URLRequest {
        guard let url = URL(string: endpoint.path, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        if let token =  LocalStorage.getString(.userToken) {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpMethod = endpoint.method.name
        return request
    }
    
    func post<D: Encodable, R: Decodable>(_ endpoint: Endpoint, content: D) async throws -> R {
        let  request = try buildRequestFor(endpoint)
        let encodedData = try JSONEncoder().encode(content)
        
        do {
            print("===Posting Request===")
            let (data, response) = try await URLSession.shared.upload(
                for: request,
                from: encodedData,
                delegate: self
            )
            
            print("===Finish Posting===")
            
            try validateResponse(response, data: data)
            try debugResponse(data)
            
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
        
        
        do {
            print("Start Update")
            let (data, response) = try await URLSession.shared.upload(
                for: request,
                from: encodedData,
                delegate: self
            )
            
            print("Finish Update")
            
            try validateResponse(response, data: data)
            
            try debugResponse(data)
            
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
            
            print("Start finish getting")
            try validateResponse(response, data: data)
            
            try debugResponse(data)
            
            let decoder = KBDecoder()
            
            let users = try decoder.decode(R.self, from: data)
            return users
        } catch {
            throw APIError.requestFailed(error)
        }
    }
    
    private func debugResponse(_ data: Data) throws {
        let content = try JSONSerialization.jsonObject(with: data, options: [])
        if let jsonObject: Any = (content as? [[String: Any]]) ?? (content as? [String: Any]) {
            print("Response JSON:", jsonObject)
        } else  {
            print("Failed to print JSON: ", String(data: data, encoding: .utf8) as Any)
        }
    }
    
    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let response = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        print("Status Code:", response.statusCode)
        
        let statusCode = response.statusCode
        if statusCode == 401 {
            print("❌ Should log out")
            let decoder = KBDecoder()
            let errorDict = try decoder.decode([String: String].self, from: data)
            if let errorMessage = errorDict["error"] {
                throw APIError.knownError(errorMessage)
            }
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

extension NetworkClient: URLSessionTaskDelegate {
    
}

