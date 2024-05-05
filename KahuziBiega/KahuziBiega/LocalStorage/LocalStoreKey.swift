//
//  LocalStoreKey.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 21/04/2024.
//

import SwiftUI

extension AppStorage {
    
    enum LocalStoreKey: String {
        case recentScreen = "app_recentScreen"
    }
    
    
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
