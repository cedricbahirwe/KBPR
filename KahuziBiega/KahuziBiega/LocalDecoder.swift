//
//  LocalDecoder.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 29/04/2024.
//

import Foundation

enum JSONParseError: Error {
    case fileNotFound
    case dataInitialisation(error: Error)
    case decoding(error: Error)
}

enum LocalDecoder {
    static private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensures consistent date parsing regardless of device's locale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC timezone
        return dateFormatter
    }()
    
    static func decodeAs<T: Decodable>() throws -> T {
        guard let path = Bundle.main.path(forResource: "response", ofType: "json") else
        {
            throw JSONParseError.fileNotFound
        }
            
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        
        do {
            let decoder = KBDecoder()
            decoder.dateDecodingStrategy = .formatted(dateFormatter) 

            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData
        } catch {
            print("Error decoding JSON:", error)
            throw error
        }
    }
}
