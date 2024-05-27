//
//  NewMessageSelectionView.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 27/05/2024.
//

import SwiftUI

struct NewMessageSelectionView: View {
    
    let didSelectNewUser: (KBChatUser) -> ()
    
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var vm = NewMessageViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(vm.errorMessage)
                
                ForEach(vm.users) { user in
                    Button {
                        dismiss()
                        didSelectNewUser(user)
                    } label: {
                        HStack(spacing: 16) {
                            KBImage(user.profilePic)
                                .frame(width: 50, height: 50)
                                .cornerRadius(25)
                            Text(user.email)
                                .foregroundColor(Color(.label))
                            Spacer()
                        }.padding(.horizontal)
                    }
                    Divider()
                        .padding(.vertical, 8)
                }
            }
            .navigationTitle("New Chat")
            .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
        }
    }
}

#Preview {
    NewMessageSelectionView(didSelectNewUser: { _ in })
}
