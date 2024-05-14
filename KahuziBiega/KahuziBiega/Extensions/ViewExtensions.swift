//
//  ViewExtensions.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 22/04/2024.
//

import SwiftUI

extension View {
    func embedInNavigation(large: Bool = true) -> some View {
        NavigationStack {
            self
                .navigationBarTitleDisplayMode(large ? .large : .inline)
        }
    }
    
    func loadingIndicator(isVisible: Bool, interactive: Bool = true) -> some View {
        ZStack {
            self
            ActivityIndicator(isVisible: isVisible, interactive: interactive)
        }
    }
}
