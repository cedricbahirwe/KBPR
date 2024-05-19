//
//  HTTPMethod.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 16/05/2024.
//

import Foundation

enum HTTPMethod: String {
    case get, post, put
    var name: String {
        rawValue.uppercased()
    }
}
