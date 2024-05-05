//
//  ContentView.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 20/04/2024.
//

import SwiftUI

enum AppRoute: RawRepresentable, Hashable {
    // Define the raw value type for the enum
    typealias RawValue = String
    
    case signUp
    case signIn
    case verification(user: KBUser)
    case content
    
    // Implement the rawValue property
    var rawValue: RawValue {
        switch self {
        case .signUp:
            return "signup"
        case .signIn:
            return "signin"
        case .verification(let user):
            return "verification-\(String(describing: user.stringify()))"
        case .content:
            return "content"
        }
    }
    
    // Implement the initializer from raw value
       init?(rawValue: RawValue) {
           switch rawValue {
           case "signup":
               self = .signUp
           case "signin":
               self = .signIn
           case let rawValue where rawValue.hasPrefix("verification-"):
               // Extracting the username from the rawValue
               let stringUser = String(rawValue.dropFirst("verification-".count))
               let user = KBUser.object(from: stringUser)
               if let user {
                   self = .verification(user: user)
               } else {
                   return nil
               }
           case "content":
               self = .content
           default:
               return nil
           }
       }
}


struct ContentView: View {
    @State private var navPath: [AppRoute] = []
    @AppStorage(.recentScreen) private var recentScreen: AppRoute = .signUp
        
    var body: some View {
        NavigationStack(path: $navPath) {
            SplashScreen()
                .onAppear() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        navPath = [.signIn] //[recentScreen]
                    }
                }
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .signUp:
                        SignUpScreen(navPath: $navPath)
                    case .signIn:
                        SignInScreen(navPath: $navPath)
                    case .content:
                        ContentTabView(navPath: $navPath)
                    case .verification(let user):
                        WaitingApprovalView(user: user, navPath: $navPath)
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
