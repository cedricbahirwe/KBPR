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
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

func hStackContent<T: View>(_ title: String, @ViewBuilder valueContent: () -> T) -> some View {
    HStack(spacing: 10) {
        Text(title)
            .fontWeight(.semibold)
        
        valueContent()
    }
}

func vStackField(_ title: String, text: Binding<String>) -> some View {
    VStack(alignment: .leading, spacing: 10) {
        Text(title)
            .fontWeight(.semibold)
        KBField("", text: text)
    }
    .foregroundStyle(.secondLabel)
    
}

func vStackContent<T: View>(_ title: String, @ViewBuilder valueContent: () -> T) -> some View {
    VStack(alignment: .leading, spacing: 10) {
        Text(title)
            .foregroundStyle(.secondLabel)
            .fontWeight(.semibold)
        valueContent()
    }
}

func vStackContent(_ title: String, value: String, _ valueWeight: Font.Weight? = nil) -> some View {
    VStack(alignment: .leading, spacing: 10) {
        Text(title)
            .fontWeight(.semibold)
        Text(value)
            .fontWeight(valueWeight)
        Divider()
    }
}
