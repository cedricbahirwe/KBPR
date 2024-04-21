//
//  HomeScreen.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 21/04/2024.
//

import SwiftUI

struct HomeScreen: View {
    @State private var selection = 1
    @Binding var navPath: [AppRoute]
    @AppStorage(.recentScreen) private var recentScreen: AppRoute?
    
    var body: some View {
        TabView(selection: $selection,
                content:  {
            Button("Tab Content 1") {
                recentScreen = nil
                navPath = [.signUp]
            }.tabItem { Text("Tab Label 1") }
                .tag(1)
            Text("Tab Content 2")
                .tabItem { Text("Tab Label 2") }
                .tag(2)
        })
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    HomeScreen(navPath: .constant([]))
}
