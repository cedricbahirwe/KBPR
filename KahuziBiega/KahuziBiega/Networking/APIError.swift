//
//  APIError.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 16/05/2024.
//

import Foundation

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
