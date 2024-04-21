//
//  Button.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 21/04/2024.
//

import SwiftUI

struct UnhighlightedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

extension ButtonStyle where Self == UnhighlightedButtonStyle {
    static var unhighlighted: UnhighlightedButtonStyle {
        return UnhighlightedButtonStyle()
    }
}




struct BorderedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
//            .padding(10)
//            .background(Color.gray.opacity(0.1))
//            .cornerRadius(8)
//            .foregroundColor(.primary)
        
            .padding(10)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder()
            }
    }
}

extension TextFieldStyle where Self == BorderedTextFieldStyle {
    static var borderedStyle: BorderedTextFieldStyle {
        BorderedTextFieldStyle()
    }
}

struct TitleThenIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}

extension LabelStyle where Self == TitleThenIconLabelStyle {
    static var titleThenIcon: TitleThenIconLabelStyle {
        TitleThenIconLabelStyle()
    }
}
