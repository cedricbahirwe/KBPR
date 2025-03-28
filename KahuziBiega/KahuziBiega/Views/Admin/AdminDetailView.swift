//
//  AdminDetailView.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 14/05/2024.
//

import SwiftUI

struct AdminDetailView: View {
    var loggedInUser = LocalStorage.getSessionUser()
    @Binding var user: KBUser
    @EnvironmentObject private var userStore: UserStore
    
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            
            VStack {
                KBImage(user.profilePic) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                }
                .frame(width: 100, height: 100)
                .background(.regularMaterial)
                .clipShape(.circle)
                
                Text("@" + user.username)
            }
            .padding(30)

    
            VStack(alignment: .leading) {
                HStack {
                    
                    vStackContent("First Name", value: user.firstName)
                    vStackContent("Last Name", value: user.lastName)
                }

                vStackContent("Email", value: user.email)
                
                vStackContent("Badge", value: user.badgeNumber, .bold)
                
                if let phoneNumber = user.phoneNumber {
                    vStackContent("Phone Number", value: phoneNumber)
                }
                
                HStack {
                    hStackContent("Role:") {
                        Text(user.role.rawValue)
                            .foregroundStyle(.accent)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                    Menu {
                        ForEach(KBUser.KBUserRole.allCases, id: \.self) { role in
                            Button(role.rawValue, action: { updateRole(to: role) })
                                .disabled(!canUpdateRoleTo(to: role))
                        }
                    } label: {
                        Text("Update")
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .foregroundStyle(.accent)
                            .background(.gray.quaternary)
                            .clipShape(.capsule)
                            .font(.callout)
                    }
                    
                }
                
                Divider()
                
                HStack {
                    hStackContent("Status:") {
                        Text(user.status.rawValue)
                            .fontWeight(.bold)
                            .foregroundStyle(getColorForUserStatus())
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Menu {
                        ForEach(KBUser.KBAccountStatus.allCases, id: \.self) { status in
                            Button(action: { updateStatus(to: status)}, label: {
                                Label(
                                    title: { Text(status.rawValue).foregroundStyle(.red) },
                                    icon: { 
                                        if user.status == status {
                                            Image(systemName: "checkmark")
                                            
                                        }
                                    }
                                )
                            })
                        }
                    } label: {
                        Text("Update")
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .foregroundStyle(.accent)
                            .background(.gray.quaternary)
                            .clipShape(.capsule)
                            .font(.callout)
                    }
                }
                
                Divider()

                hStackContent("Joined on:") {
                    Text(user.createdAt.formatted(date: .long, time: .omitted))
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }
        .padding(.horizontal)
        .navigationTitle(
            Text("@" + user.username)
        )
        .navigationBarTitleDisplayMode(.inline)
        .loadingIndicator(isVisible: isLoading)
    }
    
    private func getColorForUserStatus() -> Color {
        switch user.status {
        case .Pending: .blue
        case .Approved: .green
        case .Suspended: .yellow
        case .Banned: .red
        }
    }
    
    private func updateRole(to newRole: KBUser.KBUserRole) {
        // Perform Network Operation
        user.role = newRole
    }
    
    private func updateStatus(to newStatus: KBUser.KBAccountStatus) {
        
        guard user.status != newStatus else { return }
                
        Task {
            isLoading = true
            if let updatedUser = await userStore.updateUserStatus(user, newStatus: newStatus) {
                self.user = updatedUser
            }
            isLoading = false
        }
    }
    
    private func canUpdateRoleTo(to role: KBUser.KBUserRole) -> Bool {
        guard let loggedInUser else { return false }
        return loggedInUser.role > role
    }
}

#Preview {
    var user = KBUser.example
    user.profilePic = "https://xsgames.co/randomusers/assets/avatars/male/72.jpg"
    return AdminDetailView(
        loggedInUser: .admin,
        user: .constant(user)
    )
    .embedInNavigation()
    .environmentObject(UserStore())
}
