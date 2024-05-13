//
//  KahuziBiegaApp.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 20/04/2024.
//

import SwiftUI
import SwiftData

@main
struct KahuziBiegaApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @StateObject private var authVM = AuthenticationViewModel()
    @StateObject private var incidentsStore = IncidentsStore()
    @StateObject private var usersStore = UserStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authVM)
                .environmentObject(incidentsStore)
                .environmentObject(usersStore)
        }
        .modelContainer(sharedModelContainer)
    }
}
