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
                .tabItem { Image(systemName: "house") }
                .tag(1)
            ReportScreen().embedInNavigation()
                .tabItem { Image(systemName: "doc.text") }
                .tag(2)
            
            ChatsScreen()
                .tabItem { Image(systemName: "bubble.left.and.text.bubble.right") }
                .tag(3)
            
            AnalyticsScreen()
                .tabItem { Image(systemName: "chart.bar.xaxis") }
                .tag(4)
            
            if isAdminUser {
                AdminDashboardView()
                    .tabItem { Image(systemName: "gear") }
                    .tag(5)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    ContentTabView()
}
