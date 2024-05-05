//
//  LocalStorage.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 05/05/2024.
//

import Foundation

enum LocalStorage {
    func saveUser(_ user: KBUser, key: LocalStoreKey) throws {
        let data = try JSONEncoder().encode(user)
        
        UserDefaults.standard.setValue(data, forKey: key.rawValue)
    }
    
    func getUser(key: LocalStoreKey) -> KBUser? {
        guard let data = UserDefaults.standard.data(forKey: key.rawValue) else { return nil }
        return try? KBDecoder().decode(KBUser.self, from: data)
    }
    
    func isLoggedIn()  -> Bool {
        getUser(key: .user) != nil
    }
}
