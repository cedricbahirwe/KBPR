//
//  AdminDashboard.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 13/05/2024.
//

import SwiftUI

struct AdminDashboard: View {
    @State private var searchQuery = ""
    @EnvironmentObject private var userStore: UserStore
    @State private var isLoading = false
    var body: some View {
        
        List(userStore.allUsers) { user in
            NavigationLink {
                Text(user.fullName)
            } label: {
                HStack {
                    
                    VStack(alignment: .leading) {
                        Text(user.firstName).bold()
                        Text("Badge: \(user.badgeNumber)")
                        Text("Status: \(user.status.rawValue)")
                            Text("Joined on: \(user.createdAt.formatted(date: .long, time: .omitted))")
                    }
                }
            }
            .listRowSeparatorTint(.accent)
            
        }
        .navigationTitle("Users")
//        .navigationBarTitleDisplayMode(.large)
        .searchable(
            text: $searchQuery,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text(
                "Filter..."
            )
        )
        .overlay {
            if isLoading { ProgressView()}
        }
        .task {
            isLoading = true
            await userStore.getAllUsers()
            isLoading = false
        }
        .toolbar(.visible, for: .navigationBar)

        
    }
       
}


#Preview {
    NavigationStack {
        AdminDashboard()
        
            .environmentObject(UserStore())
    }
}

@MainActor
final class UserStore: ObservableObject {
    @Published var allUsers = [KBUser]()
    
    init() {
        if let cache = Cacher<[KBUser]>.get(for: .allUsers) {
            self.allUsers = cache.data
        }
    }
    
    func getAllUsers() async {
        do {
            self.allUsers = try await NetworkClient.shared.get(.allUsers)
            Cacher.cache(self.allUsers, for: .allUsers)
        } catch {
            print("Error getting all users", error.localizedDescription)
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
