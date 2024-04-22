//
//  ViewExtensions.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 22/04/2024.
//

import SwiftUI

extension View {
    func embedInNavigation() -> some View {
        NavigationStack {
            self
        }
    }
}
