//
//  SplashScreen.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 21/04/2024.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack {
            Image(.splashscreen)
                .resizable()
                .ignoresSafeArea()
        }
    }
}

#Preview {
    SplashScreen()
}
