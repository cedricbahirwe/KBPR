//
//  AdminNewUserView.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 14/05/2024.
//

import SwiftUI

struct AdminNewUserView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var registerModel = SignUpModel.example
    @EnvironmentObject var authVM: AuthenticationViewModel
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                NewUserFormView(registerModel: $registerModel)
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
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.regularMaterial)
            }
        }
    }
}

#Preview {
    AdminNewUserView()
        .embedInNavigation(large: false)
}
