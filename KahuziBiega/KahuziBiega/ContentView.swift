//
//  ContentView.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 20/04/2024.
//

import SwiftUI

enum AppRoute: Int {
    case signUp
    case signIn
    case home
}


struct ContentView: View {
    @State private var navPath: [AppRoute] = []
    @AppStorage(.recentScreen) private var recentScreen: AppRoute = .signUp
    
    var body: some View {
        NavigationStack(path: $navPath) {
            SplashScreen()
                .onAppear() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        navPath = [recentScreen]
                    }
                }
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .signUp:
                        SignUpScreen(navPath: $navPath)
                    case .signIn:
                        SignInScreen(navPath: $navPath)
                    case .home:
                        HomeScreen(navPath: $navPath)
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
