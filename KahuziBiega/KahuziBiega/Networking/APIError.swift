//
//  APIError.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 16/05/2024.
//

import Foundation

// TODO: Customize Error Messages
enum APIError: LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case invalidData
    
    case badRequest(Int)
    case serverError(Int)
    case unknowStatus(Int)
    
    case unableToDecodeResponse(Error)
    case knownError(String)
    
    var errorDescription: String? {
        switch self {
        case .unableToDecodeResponse(let error),
                .requestFailed(let error):
            return error.localizedDescription
        case .knownError(let message):
            return message
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "A bad response was receive, try again later"
        case .invalidData:
            return "Invalid data, try again later"
        case .badRequest(_):
            return "Bad Rquest, try again later"
        case .serverError(_):
            return "Unknown Error ta, try again later"
        case .unknowStatus(_):
            return "Uknown Status, try again later"
        }
    }
}
