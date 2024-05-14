//
//  KBField.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 14/05/2024.
//

import SwiftUI

struct KBField: View {
    let placeholder: LocalizedStringKey
    @Binding var text: String
    let contentType: UITextContentType?
    
    init(_ placeholder: LocalizedStringKey, text: Binding<String>, contentType: UITextContentType? = .none) {
        self.placeholder = placeholder
        self._text = text
        self.contentType = contentType
    }
    
    var body: some View {
        textFieldView
            .textFieldStyle(.borderedStyle)
            .textContentType(contentType)
    }
    
    var isSecure: Bool = false
    
    @ViewBuilder
    private var textFieldView: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
    }
}

extension KBField {
    func toSecureField() -> KBField {
        var view = self
        view.isSecure = true
        return view
    }
}

//#Preview {
//    KBField()
//}
