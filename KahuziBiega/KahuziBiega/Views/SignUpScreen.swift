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
    @Binding var navPath: [AuthRoute]
    @AppStorage(.authRecentScreen) private var authRecentScreen: AuthRoute?
    
    @EnvironmentObject var authVM: AuthenticationViewModel
    
    @State private var registerModel = SignUpModel.example
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
                
                
                NewUserFormView(registerModel: $registerModel)
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
                let user = try await authVM.registerNewUser(registerModel)
                
                let destination = AuthRoute.verification(user: user)
                authRecentScreen = destination
                navPath = [destination]
            }
        }
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

struct NewUserFormView: View {
    @Binding var registerModel: SignUpModel
    var body: some View {
        VStack(spacing: 12) {
            
            KBField("Username", text: $registerModel.username)
            
            KBField("Email", text: $registerModel.email)
            
            KBField("Password", text: $registerModel.password)
            
            HStack {
                KBField("First Name", text: $registerModel.firstName)
                
                KBField("Last Name", text: $registerModel.firstName)
                
            }
            
            KBField("Badge Number", text: $registerModel.email)
            
            KBField(
                "Phone Number",
                text: Binding(get: {
                    registerModel.phoneNumber ?? ""
                }, set: { newValue in
                    let cleanNumber = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    registerModel.phoneNumber = cleanNumber.isEmpty ? nil : cleanNumber
                })
            )
            
        }
    }
}
