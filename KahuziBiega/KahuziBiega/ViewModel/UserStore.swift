//
//  UserStore.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 14/05/2024.
//

import Foundation

@MainActor
final class UserStore: ObservableObject {
    @Published var allUsers = [KBUser]()
    // TODO: Need to implement error and alerts
    
    init() {
        if let cache = Cacher<[KBUser]>.get(for: .allUsers) {
            self.allUsers = cache.data
        }
    }
    
    func getAllUsers(forced: Bool = false) async {
        guard forced || allUsers.isEmpty else { return }
        do {
            self.allUsers = try await NetworkClient.shared.get(.allUsers)
            Cacher.cache(self.allUsers, for: .allUsers)
        } catch {
            print("Error getting all users", error.localizedDescription)
        }
    }
    
    func updateUserStatus(_ user: KBUser, newStatus: KBUser.KBAccountStatus) async -> KBUser? {
        do {
            let statusUpdate = ["status": newStatus.rawValue]
            let updatedUser: KBUser = try await NetworkClient.shared.put(.updateStatus(user: user.id), content: statusUpdate)
            return updatedUser
        } catch {
            print("Error update status: ", error.localizedDescription)
            return nil
        }
    }
}

struct Cacher<T: Codable>: Codable {
    let cachedAt: Date
    let data: T
    
    var isValid: Bool {
        let cacheValidityInterval: TimeInterval = 3600 // 1 hour in seconds
                
        // Calculate the time difference between the current time and the cached time
        let timeDifference = Date().timeIntervalSince(cachedAt)
        
        // Return true if the time difference is within the validity interval, false otherwise
        return timeDifference <= cacheValidityInterval
    }
}

extension Cacher {
    static func cache(_ data: T, for key: LocalStoreKey) {
        let cache = Cacher(cachedAt: .now, data: data)
        try? LocalStorage.save(cache, key: key)
    }
    
    static func get(for key: LocalStoreKey) -> Cacher? {
        // TODO: Here, we could check if valid before returning
        try? LocalStorage.get(for: key)
    }
}

