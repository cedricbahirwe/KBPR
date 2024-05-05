//
//  SignUpScreen.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 20/04/2024.
//

import SwiftUI

struct SignUpModel: Encodable {
    var username = ""
    var email = ""
    var password = ""
    var firstName = ""
    var lastName = ""
    var badgeNumber = ""
    var phoneNumber: String?
    
    static let example = SignUpModel(username: "driosman", email: "newone@gmail.com", password: "driosman", firstName: "Drios", lastName: "Man", badgeNumber: "Drios1234", phoneNumber: "0782628000")
}

struct SignUpScreen: View {
    @Binding var navPath: [AppRoute]
    @AppStorage(.recentScreen) private var recentScreen: AppRoute?
    
    @EnvironmentObject var authVM: AuthenticationViewModel
    
    @State private var signupModel = SignUpModel.example
    @State private var isSignUp = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Image(.signupHeader)
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
            
            
            VStack(spacing: 30) {
                
                Image(.signupHeader)
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()
                    .hidden()
                
                
                VStack(spacing: 12) {
                    
                    KBField("Username", text: $signupModel.username)
                    
                    KBField("Email", text: $signupModel.email)
                    
                    KBField("Password", text: $signupModel.password)
                    
                    HStack {
                        KBField("First Name", text: $signupModel.firstName)
                        
                        KBField("Last Name", text: $signupModel.firstName)
                        
                    }
                    
                    KBField("Badge Number", text: $signupModel.email)
                    
                    KBField(
                        "Phone Number",
                        text: Binding(get: {
                            signupModel.phoneNumber ?? ""
                        }, set: { newValue in
                            let cleanNumber = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                            signupModel.phoneNumber = cleanNumber.isEmpty ? nil : cleanNumber
                        })
                    )
                    
                }
                .padding()
                .background(.background)
                
                Button(action: {
                    performRegistration()
                }, label: {
                    Label("Sign Up", systemImage: "arrow.forward.circle.fill")
                        .font(.largeTitle)
                        .bold()
                        .labelStyle(.titleThenIcon)
                })
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
       
            ActivityIndicator(isVisible: authVM.isLoading)
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                
                Button {
                    navPath.append(.signIn)
                } label: {
                    Image(.signinBtn)
                }
                .buttonStyle(.unhighlighted)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func performRegistration() {
        Task {
            print("Signing Up")
            do {
                let user = try await authVM.signup(signupModel)
                
                let destination = AppRoute.verification(user: user)
                recentScreen = destination
                navPath = [destination]
            }
        }
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

#Preview {
    SignUpScreen(navPath: .constant([]))
        .environmentObject(AuthenticationViewModel())
}



struct ActivityIndicator: View {
    var isVisible: Bool
    var interactive: Bool = true
    var body: some View {
        Group {
            if !interactive {
                Color.black.opacity(0.005)
            }
            if isVisible {
                ProgressView()
                    .padding(25)
                    .background(.thinMaterial, in: .rect(cornerRadius: 15))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                EmptyView()
            }
        }
       
    }
}
