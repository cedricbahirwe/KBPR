//
//  AdminNewUserView.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 14/05/2024.
//

import SwiftUI

struct AdminNewUserView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var registerModel = SignUpModel()
    @EnvironmentObject var authVM: AuthenticationStore
    var onCreateNewUser: (Bool) -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                NewUserFormView(registerModel: $registerModel)
                    .padding(.top)
            }
            .padding(.horizontal)
            .navigationTitle("Add New Uer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Go Back", systemImage: "chevron.left", action: dismiss.callAsFunction)
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack {
                    Button("Add user") {
                        addNewUser()
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.regularMaterial)
            }
            .loadingIndicator(isVisible: authVM.isLoading, interactive: false)
        }
    }
    
    private func addNewUser() {
        Task {
            do {
                _ = try await authVM.registerNewUser(registerModel)
                onCreateNewUser(true)
                dismiss()
            }
        }
    }
}

#Preview {
    AdminNewUserView(onCreateNewUser: { _ in })
        .embedInNavigation(large: false)
        .environmentObject(AuthenticationStore())
}
