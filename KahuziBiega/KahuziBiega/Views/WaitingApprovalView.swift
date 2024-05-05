//
//  WaitingApprovalView.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 05/05/2024.
//

import SwiftUI

struct WaitingApprovalView: View {
    let user: KBUser
    @Binding var navPath: [AppRoute]
    var body: some View {
        VStack(alignment: .leading) {
            Text("Hello, \(user.username)!")
                .font(.largeTitle)
                .bold()
                .fontDesign(.rounded)
                .padding(25)
            
            VStack(alignment: .leading, spacing: 25) {
                Text("👋🏽")
                    .font(.system(size: 100))
                    .frame(maxWidth: .infinity)
                
                Text("We're waiting for the **Admin** to verify your account\n\nWe'll let you know once it's done")
                    .font(.title2)

                
                 Text("You can refresh your status manually by clicking the button below")
                     .foregroundStyle(.white.opacity(0.6))
                
                Button("Refresh") {
                    // refresh status
                }
                .buttonBorderShape(.capsule)
                .buttonStyle(.bordered)
                .foregroundStyle(.accent)
                
                Spacer()
            }
            .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(25)
        .background(.black)
        .foregroundStyle(.regularMaterial)
        .fontDesign(.rounded)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    WaitingApprovalView(user: .example, navPath: .constant([]))
}
