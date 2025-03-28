//
//  AdminDashboardView.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 05/05/2024.
//

import SwiftUI

struct AdminDashboardView: View {
    @State private var searchText = ""
    @EnvironmentObject private var userStore: UserStore
    @State private var isLoading = false
    @State private var navPath: [ContentRoute] = []
    @State private var showSheet = false

    var filteredUsers: [Binding<KBUser>] {
        let allUsersBinding = $userStore.allUsers
        return allUsersBinding.filter { userBinding in
            searchText.isEmpty || userBinding.wrappedValue.badgeNumber.localizedCaseInsensitiveContains(searchText) ||
            userBinding.firstName.wrappedValue.localizedCaseInsensitiveContains(searchText) ||
            userBinding.lastName.wrappedValue.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack(path: $navPath) {
            List(filteredUsers) { $user in
                NavigationLink {
                    AdminDetailView(user: $user)
                } label: {
                    HStack {
                        
                        VStack(alignment: .leading) {
                            Text(user.fullName).bold()
                            Text("Badge: \(Text(user.badgeNumber).underline().foregroundStyle(.accent))")
                            Text("Status: \(user.status.rawValue)")
                            Text("Joined on: \(user.createdAt.formatted(date: .long, time: .omitted))")
                        }
                    }
                }
                .listRowSeparatorTint(.accent)
                
            }
            .navigationTitle("Users")
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Text(
                    "Filter..."
                )
            )
            .refreshable {
                loadContent(forced: true)
            }
            .overlay {
                if isLoading { ProgressView() }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add user", systemImage: "plus") { showSheet.toggle() }
                }
            }
            .fullScreenCover(isPresented: $showSheet) {
                AdminNewUserView { hasCreacted in
                    if hasCreacted {
                        loadContent(forced: true)
                    }
                }
            }
            .task {
                loadContent(forced: false)
            }
        }
    }
    
       
    private func loadContent(forced: Bool) {
        Task {
            isLoading = true
            await userStore.getAllUsers(forced: forced)
            isLoading = false
        }
    }
}

#Preview {
    AdminDashboardView()
        .environmentObject(UserStore())
}

enum ContentRoute: Hashable {
    case content
}
