//
//  AdminDashboardView.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 05/05/2024.
//

import SwiftUI

struct AdminDashboardView: View {
    @State private var searchQuery = ""
    @EnvironmentObject private var userStore: UserStore
    @State private var isLoading = false
    @State private var navPath: [ContentRoute] = []
    @State private var showSheet = false
    @State private var url: URL?
    @State private var imageData: Data?
    var body: some View {
        NavigationStack(path: $navPath) {
            List($userStore.allUsers) { $user in
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
                text: $searchQuery,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Text(
                    "Filter..."
                )
            )
            .refreshable {
                loadContent(forced: true)
            }
            .overlay {
                if isLoading { ProgressView()}
                VStack {
                    if let url {
                        AsyncImage(url: url)
                            .background(.red)
                            .frame(width: 50, height: 50)
                    }
                    
                    if let data = imageData {
                        Image(uiImage: UIImage(data: data) ?? .init())
                            .resizable()
                            .frame(width: 50, height: 50)
                            .background(.green)
                    }
                }
            }
//            .toolbar(.visible, for: .navigationBar)
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
