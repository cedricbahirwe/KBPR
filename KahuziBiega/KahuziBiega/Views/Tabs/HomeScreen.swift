//
//  HomeScreen.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 21/04/2024.
//

import SwiftUI

struct HomeScreen: View {
    @Binding var navPath: [AppRoute]
    var body: some View {
        Text("Home Screen")
    }
}

#Preview {
    HomeScreen(navPath: .constant([]))
}
