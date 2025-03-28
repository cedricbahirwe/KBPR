//
//  WaitingApprovalView.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 05/05/2024.
//

import SwiftUI

struct WaitingApprovalView: View {
    @State var user: KBUser
    @Binding var navPath: [AuthRoute]
    @AppStorage(.authRecentScreen) private var authRecentScreen: AuthRoute?
    @AppStorage(.isLoggedIn) private var isLoggedIn: Bool = false
    @EnvironmentObject private var authStore: AuthenticationStore
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text("Hello, \(user.username)!")
                    .font(.largeTitle)
                    .bold()
                    .fontDesign(.rounded)
                
                VStack(alignment: .leading, spacing: 25) {
                    Text("👋🏽")
                        .font(.system(size: 100))
                        .frame(maxWidth: .infinity)
                    
                    Text("We're waiting for the **Admin** to verify your account\n\nWe'll let you know once it's done")
                        .font(.title2)
                    
                    
                    Text("You can refresh your status manually by clicking the button below")
                        .foregroundStyle(.white.opacity(0.6))
                    
                    Button("Refresh") {
                        Task {
                            await performVerification()
                        }
                    }
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.bordered)
                    .foregroundStyle(.accent)
                    
                    Spacer()
                    
                    Button("Logout") {
                        LocalStorage.clear()
                        navPath = []
                    }
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.bordered)
                    .foregroundStyle(.red)
                }
                .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(25)
            .background(.black)
            
            ActivityIndicator(isVisible: authStore.isLoading, interactive: true)
        }
        .foregroundStyle(.regularMaterial)
        .fontDesign(.rounded)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await performVerification()
        }
    }
    
    private func performVerification() async {
        let status = try? await authStore.checkUserStatus(user)
        
        if status == .Approved {
            goToContent()
        }
    }
    
    private func goToContent() {
        isLoggedIn = true
        authRecentScreen = nil
    }
}

#Preview {
    WaitingApprovalView(user: .example, navPath: .constant([]))
        .environmentObject(AuthenticationStore())
}
