//
//  LocalStoreKey.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 21/04/2024.
//

import SwiftUI

enum LocalStoreKey: String {
    case recentScreen = "app_recentScreen"
    
    case user = "app_user"
    
    case userToken
    
    
    // Admin
    case allUsers
}

protocol LocalStorageSetter {
    associatedtype Key = LocalStoreKey
    static func setString(_ value: String, for key: Key)
    static func setBool(_ value: Bool, for key: Key)
}

protocol LocalStorageGetter {
    associatedtype Key = LocalStoreKey
    static func getString(_ key: Key) -> String?
    static func getBool(_ key: Key) -> Bool
}

extension AppStorage {
  
    // MARK: - Int
    
    init<R>(_ key: LocalStoreKey, store: UserDefaults? = nil) where Value == R?, R : RawRepresentable, R.RawValue == Int {
        self.init(key.rawValue, store: store)
    }
    
    init(wrappedValue: Value, _ key: LocalStoreKey, store: UserDefaults? = nil) where Value : RawRepresentable, Value.RawValue == Int {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }
    
    
    // MARK: - String
    init<R>(_ key: LocalStoreKey, store: UserDefaults? = nil) where Value == R?, R : RawRepresentable, R.RawValue == String {
        self.init(key.rawValue, store: store)
    }
    
    init(wrappedValue: Value, _ key: LocalStoreKey, store: UserDefaults? = nil) where Value : RawRepresentable, Value.RawValue == String {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }
}
