//
//  ContentView.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 20/04/2024.
//

import SwiftUI

enum AppRoute {
    case signUp
    case signIn
    case home
}

struct ContentView: View {
    @State private var navPath: [AppRoute] = []
    
    var body: some View {
        NavigationStack(path: $navPath) {
            SplashScreen()
                .onAppear() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        navPath = [.signUp]
                    }
                }
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .signUp:
                        SignUpScreen(navPath: $navPath)
                    case .signIn:
                        SignInScreen(navPath: $navPath)
                    case .home:
                        ContentView()
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
