//
//  NewMessageViewModel.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 27/05/2024.
//

import Foundation

final class NewMessageViewModel: ObservableObject {
    
    @Published var users = [KBChatUser]()
    @Published var errorMessage = ""
    
    init() {
        fetchAllUsers()
    }
    
    private func fetchAllUsers() {
        KBFBManager.shared.firestore.collection("users")
            .getDocuments { documentsSnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch users: \(error)"
                    print("Failed to fetch users: \(error)")
                    return
                }
                
                print("Fetching users")
                
                documentsSnapshot?.documents.forEach({ snapshot in
                    let user = try? snapshot.data(as: KBChatUser.self)
                    if let user, user.uid != KBFBManager.shared.auth.currentUser?.uid {
                        self.users.append(user)
                    }
                    
                })
            }
    }
}
