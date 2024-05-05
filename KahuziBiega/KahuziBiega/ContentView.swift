//
//  ContentView.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 20/04/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var navPath: [AppRoute] = []
    @AppStorage(.recentScreen) private var recentScreen: AppRoute = .signUp
        
    var body: some View {
        NavigationStack(path: $navPath) {
            SplashScreen()
                .onAppear() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        navPath = [recentScreen]// [.signIn] //[recentScreen]
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
