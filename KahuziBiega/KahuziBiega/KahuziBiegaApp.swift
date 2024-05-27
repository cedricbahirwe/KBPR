//
//  KahuziBiegaApp.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 20/04/2024.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct KahuziBiegaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
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
    
    @StateObject private var authVM = AuthenticationStore()
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


final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        KBPusherManager.shared.configure()
        return true
    }
}
