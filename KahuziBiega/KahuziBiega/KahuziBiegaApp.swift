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
    
    @StateObject private var pusherManager = KBPusherManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authVM)
                .environmentObject(incidentsStore)
                .environmentObject(usersStore)
                .environmentObject(pusherManager)
        }
        .modelContainer(sharedModelContainer)
    }
}

import PushNotifications


final class AppDelegate: NSObject, UIApplicationDelegate {
    let pushNotifications = PushNotifications.shared
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        self.pushNotifications.start(instanceId: "e05a8e13-930f-46f4-84b9-3585b6f50178")
        self.pushNotifications.registerForRemoteNotifications(options: [.alert, .sound])
        try! self.pushNotifications.addDeviceInterest(interest: "incidents")
        KBPusherManager.shared.configure()
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
//        self.pushNotifications
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.pushNotifications.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("NOTIFI INFO", userInfo)

        self.pushNotifications.handleNotification(userInfo: userInfo)
        
    }
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
            let userInfo = response.notification.request.content.userInfo
            
        if let customData = userInfo["data"] as? [AnyHashable: Any], let data = customData["incidentId"] {
                print("Incident ID received: \(data)")
                // Handle the custom data, for example, navigate to a specific view controller
//                navigateToSpecificViewController(with: customData)
            }
        
        print("Data", userInfo)
            
            completionHandler()
        }
}
