//
//  ContentTabView.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 21/04/2024.
//

import SwiftUI

struct ContentTabView: View {
    @AppStorage("tab_selection") private var selection = 1
    private var loggedInUser = LocalStorage.getSessionUser()
    private var isAdminUser: Bool {
        return loggedInUser?.role == .Admin ||
        loggedInUser?.role == .SuperAdmin
    }
    var body: some View {
        TabView(selection: $selection) {
            HomeScreen()
                .embedInNavigation()
                .tabItem { Image(systemName: "house") }
                .tag(1)
            
            ChatsScreen()
                .tabItem { Image(systemName: "bubble.left.and.text.bubble.right") }
                .tag(2)
            
            AnalyticsScreen()
                .tabItem { Image(systemName: "chart.bar.xaxis") }
                .tag(3)
            
            if isAdminUser {
                AdminDashboardView()
                    .tabItem { Image(systemName: "gear") }
                    .tag(4)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    ContentTabView()
}
