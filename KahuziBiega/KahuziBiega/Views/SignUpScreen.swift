//
//  SignUpScreen.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 20/04/2024.
//

import SwiftUI

struct SignUpModel: Codable {
    var phoneNumber: String
    var fullName: String
    var email: String
    var password: String
    var parkID: String
    
    static let empty = SignUpModel(phoneNumber: "", fullName: "", email: "", password: "", parkID: "")
}

struct SignUpScreen: View {
    @Binding var navPath: [AppRoute]
    @State private var signupModel = SignUpModel.empty
    @State private var isSignUp = false
    
    var body: some View {
        VStack {
            Image(.signupHeader)
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                
                KBField("Phone Number", text: $signupModel.phoneNumber)
                
                KBField("Full Name", text: $signupModel.fullName)
                
                KBField("Email", text: $signupModel.email)
                
                KBField("Password", text: $signupModel.email)
                
                KBField("Park ID /  Badge Number", text: $signupModel.email)
                
                
                
            }
            .padding()
            
            Button(action: {
                print("Signing Up")
            }, label: {
                Label("Sign Up", systemImage: "arrow.forward.circle.fill")
                    .font(.largeTitle)
                    .bold()
                    .labelStyle(.titleThenIcon)
            })
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                
                Button {
                    navPath.append(.signIn)
                    print("Signing In")
                } label: {
                    Image(.signinBtn)
                }
                .buttonStyle(.unhighlighted)
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
    }
}

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
        TextField(placeholder, text: $text)
            .textFieldStyle(.borderedStyle)
            .textContentType(contentType)
    }
}

#Preview {
    SignUpScreen(navPath: .constant([]))
}
