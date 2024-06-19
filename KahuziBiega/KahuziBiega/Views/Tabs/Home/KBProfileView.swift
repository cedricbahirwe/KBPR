//
//  KBProfileView.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 19/06/2024.
//

import SwiftUI

struct KBProfileView: View {
    @Environment(\.dismiss) private var dismiss
    let user: KBUser
    var body: some View {
        VStack(spacing: 20) {
            Text(user.usernameFormatted)
                .fontDesign(.monospaced)
                .foregroundStyle(.tint)
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    vstack("First Name", user.firstName)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    vstack("Last Name", user.lastName)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                HStack {
                    vstack("Badge", user.badgeNumber)
                        .foregroundStyle(.tint)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let phoneNumber = user.phoneNumber {
                        vstack("Phone Number", phoneNumber)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                
                vstack("Email", user.email)
                
                
                vstack("Member since", user.createdAt.formatted(date: .long, time: .omitted))
                
                Button {
                    dismiss()
                    NotificationCenter.default.post(name: .unauthorizedRequest, object: nil)

                } label: {
                    Text("Log out")
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(.red, in: .capsule)
                        
                }
                .tint(.white)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding([.horizontal, .bottom])

    }
    
    @ViewBuilder
    private func vstack(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.gray)
            
            Text(value)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    KBProfileView(user: LocalStorage.getSessionUser() ?? KBUser.admin)
        
}
