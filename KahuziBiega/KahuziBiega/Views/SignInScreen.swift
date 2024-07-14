//
//  SignInScreen.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 21/04/2024.
//

import SwiftUI

struct SignInScreen: View {
    
    @Binding var navPath: [AuthRoute]
    @AppStorage(.authRecentScreen) private var authRecentScreen: AuthRoute?
    @EnvironmentObject private var authStore: AuthenticationStore
    @AppStorage(.isLoggedIn) private var isLoggedIn: Bool = false
    @State private var loginModel = LoginModel.admin
    @State private var alertItem: KBAlert?
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            VStack {
                Image(.signinHeader)
                    .resizable()
                    .scaledToFit()
                    .overlay(alignment: .bottomLeading) {
                        Image(.signinLabel)
                            .padding()
                    }
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    
                    KBField("Email", text: $loginModel.email, contentType: .emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    
                    KBField("Password ", text: $loginModel.password)
                        .toSecureField()
                    
                    
                    Button(action: {
                        performLogin()
                    }, label: {
                        Label("Sign In", systemImage: "arrow.forward.circle.fill")
                            .font(.largeTitle)
                            .bold()
                            .labelStyle(.titleThenIcon)
                    })
                }
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .padding(20)
                .background(.background.opacity(0.6))
                .clipShape(.rect(cornerRadius: 25.0))
                .overlay {
                    RoundedRectangle(cornerRadius: 25.0)
                        .stroke(
                            Color(red: 222/255, green: 225/255, blue: 231/255)
                            , lineWidth: 2
                        )
                    
                }
                
                .padding(20)
                
                
                Spacer()
            }
            .alert(alertItem?.title ?? "", isPresented: $showAlert, presenting: alertItem) { _ in
            } message: {article in
                Text(article.description)
            }
            
            ActivityIndicator(isVisible: authStore.isLoading, interactive: true)
        }
        .background(
            Image(.authBackground)
                .resizable()
                .ignoresSafeArea()
        )
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                
                Button {
                    navPath = [.signUp]
                    print("Signing Up")
                } label: {
                    Image(.signupBtn)
                }
                .buttonStyle(.unhighlighted)
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
//        .alert(alert?.title ?? "", isPresented: $showAlert, presenting: alertItem) { alert in
//            Button("Cancel", role: .cancel) {}
//        } message: { alert in
//            Text(alert.message)
//        }
//        .alert("", isPresented: $showAlert, presenting: alert) { alert in
//            Alert(title: Text(alert.title),
//                  message: Text(alert.message))
//        }
    }
    
    private func performLogin() {
        Task {
            print("Signing In")
            
            do {
                let user = try await authStore.login(model: loginModel)
                if user.status == .Approved {
                    try LocalStorage.saveSessionUser(user)
                    goToContent()
                } else {
                    try LocalStorage.saveAUser(user)
                    let destination = AuthRoute.verification(user: user)
                    authRecentScreen = destination
                    navPath = [destination]
                }
            } catch {
                self.alertItem = .init(description: error.localizedDescription)
                self.showAlert = true
            }
        }
    }
    
    private func goToContent() {
        isLoggedIn = true
        authRecentScreen = nil
    }
}

#Preview {
    SignInScreen(navPath: .constant([]))
}

extension SignInScreen {
    struct LoginModel: Encodable {
        var email: String = ""
        var password: String = ""
        
        static let example = LoginModel(
            email: "newone@gmail.com",
            password: "driosman"
        )
        static let admin = LoginModel(
            email: "adminSuper@gmail.com",
            password: "abc123"
        )
        func getValidationError() -> String? {
            if email.count < 3 {
                return "Username must be at least 3 characters long."
            }
            if password.count < 5 {
                return "Password must be at least 5 characters long."
            }
            return nil // No validation errors
        }
    }
}

struct KBAlert: Identifiable {
    var id: UUID { UUID() }
    let title: String
    let description: String
    
    init(title: String = "Error", description: String) {
        self.title = title
        self.description = description
    }
}
