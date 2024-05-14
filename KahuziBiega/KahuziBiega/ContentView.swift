//
//  ContentView.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 20/04/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var authPath: [AuthRoute] = []
    @AppStorage(.authRecentScreen) private var authRecentScreen: AuthRoute = .signUp
    @AppStorage(.isLoggedIn) private var isLoggedIn: Bool = false
    @State private var isShowingSplashScreen = true
    
    var body: some View {
        if isLoggedIn {
            
            ContentTabView()
                .opacity(isShowingSplashScreen ? 0 : 1)
                .overlay {
                    SplashScreen()
                        .opacity(isShowingSplashScreen ? 1 : 0)
                        .onAppear() {
                            withAnimation(.easeInOut(duration: 1.0)) {
                                isShowingSplashScreen = false
                            }
                        }
                }
                .onReceive(NotificationCenter.default.publisher(for: .unauthorizedRequest)) { _ in
                    LocalStorage.clear()
                    isLoggedIn = false
                }
        } else {
            NavigationStack(path: $authPath) {
                SplashScreen()
                    .onAppear() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            authPath = [authRecentScreen]
                        }
                    }
                    .navigationDestination(for: AuthRoute.self) { route in
                        switch route {
                        case .signUp:
                            SignUpScreen(navPath: $authPath)
                        case .signIn:
                            SignInScreen(navPath: $authPath)
                        case .verification(let user):
                            WaitingApprovalView(user: user, navPath: $authPath)
                        }
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
