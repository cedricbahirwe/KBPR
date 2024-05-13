//
//  LocalStorage.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 05/05/2024.
//

import Foundation

enum LocalStorage {
    private static let defaults = UserDefaults.standard
    static func saveUser(_ user: KBUser) throws {
        let data = try JSONEncoder().encode(user)
        
        defaults.setValue(data, forKey: LocalStoreKey.user.rawValue)
    }
    
    static func getUser() -> KBUser? {
        guard let data = defaults.data(forKey: LocalStoreKey.user.rawValue) else { return nil }
        do {
            return try KBDecoder().decode(KBUser.self, from: data)
        } catch {
            defaults.setNilValueForKey(LocalStoreKey.user.rawValue)
            return nil
        }
    }
    
    static func save<T: Codable>(_ data: T, key: LocalStoreKey) throws {
        do {
            let data = try JSONEncoder().encode(data)
            defaults.setValue(data, forKey: key.rawValue)
        } catch {
            throw error
        }
    }
    
    static func get<T: Codable>(for key: LocalStoreKey) throws -> T? {
        do {
            guard let data = defaults.data(forKey: key.rawValue) else { return nil }
            let result = try JSONDecoder().decode(T.self, from: data)
            return result
        } catch {
            throw error
        }
    }
    
    static func deserialize<T: Decodable>(json: Data) throws -> T {
        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
        //        decoder.dateDecodingStrategy = .formatted(DateFormatter.databaseFormat)
        
        do {
            return try decoder.decode(T.self, from: json)
        } catch let error {
            debugPrint("Deserializing failed: \(error)\n in class: \(String(describing: T.self))")
            throw error
        }
    }
    
    static func serialize<T: Encodable>(object: T) throws -> Data {
        let encoder = JSONEncoder()
//        encoder.keyEncodingStrategy = .convertToSnakeCase
//        encoder.dateEncodingStrategy = .formatted(DateFormatter.databaseFormat)
        do {
            return try encoder.encode(object)
        } catch let error {
            assert(false, "Serializing failed: \(error)")
            throw error
        }
    }
    
    static func isLoggedIn()  -> Bool {
        getUser() != nil
    }
    
    static func saveAUser(_ user: KBUser) throws {
        let data = try JSONEncoder().encode(user)
        
        defaults.setValue(data, forKey: user.id.uuidString)
    }
    
    static func getAUser(for userID: KBUser.ID) -> KBUser? {
        guard let data = defaults.data(forKey: userID.uuidString) else { return nil }
        do {
            return try KBDecoder().decode(KBUser.self, from: data)
        } catch {
            defaults.removeObject(forKey: userID.uuidString)
            return nil
        }
    }
    
    
}

extension LocalStorage: LocalStorageGetter {
    static func getString(_ key: LocalStoreKey) -> String? {
        defaults.string(forKey: key.rawValue)
    }
    
    static func getBool(_ key: LocalStoreKey) -> Bool {
        defaults.bool(forKey: key.rawValue)
    }
}

extension LocalStorage: LocalStorageSetter {
    static func setString(_ value: String, for key: LocalStoreKey) {
        defaults.setValue(value, forKey: key.rawValue)
    }
    
    static func setBool(_ value: Bool, for key: LocalStoreKey) {
        defaults.setValue(value, forKey: key.rawValue)
    }
    
    
//    static func getString(_ key: LocalStoreKey) -> String? {
//        defaults.string(forKey: key.rawValue)
//    }
//    
//    static func getBool(_ key: LocalStoreKey) -> Bool {
//        defaults.bool(forKey: key.rawValue)
//    }
}

//enum Schema {
//    static func deserialize<T: Decodable>(json: Data) throws -> T {
//        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
////        decoder.dateDecodingStrategy = .formatted(DateFormatter.databaseFormat)
//     
//        do {
//            return try decoder.decode(T.self, from: json)
//        } catch let error {
//            debugPrint("Deserializing failed: \(error)\n in class: \(String(describing: T.self))")
//            #if DEBUG_PROD
//            fatalError()
//            #else
//            throw error
//            #endif
//        }
//    }
//    
//    static func serialize<T: Encodable>(object: T) throws -> Data {
//        let encoder = JSONEncoder()
//        encoder.keyEncodingStrategy = .convertToSnakeCase
////        encoder.dateEncodingStrategy = .formatted(DateFormatter.databaseFormat)
//        do {
//            return try encoder.encode(object)
//        } catch let error {
//            assert(false, "Serializing failed: \(error)")
//            throw error
//        }
//    }
//}

//extension Encodable {
//    var paramsDictionary: [String: Any]? {
//        let encoder = JSONEncoder()
//        encoder.keyEncodingStrategy = .convertToSnakeCase
//        encoder.dateEncodingStrategy = .formatted(DateFormatter.databaseFormat)
//        guard let data = try? encoder.encode(self) else { return nil }
//        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
//    }
//}

