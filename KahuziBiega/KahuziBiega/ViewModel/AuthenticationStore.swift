//
//  AuthenticationStore.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 05/05/2024.
//

import Foundation


// TODO: - Improve printing to be helpful fast

@MainActor
final class AuthenticationStore: ObservableObject {
    @Published var isLoading = false
//    @Published var isLoggedIn = false
    
    
    func login(model: SignInScreen.LoginModel) async throws -> KBUser {
        isLoading = true
        do {
            let response: KBUserData = try await NetworkClient.shared.post(.login, content: model)
            LocalStorage.setString(response.token, for: .userToken)
            
            
            // Login User on Firebase
            try await loginUserToFirebase(
                email: model.email,
                password: model.password,
                user: response.data
            )
            
            isLoading = false
            print("Login success", response.data.username)
            return response.data
        } catch let error as APIError {
            isLoading = false
            print("Failed to login, Internal Error:", error.message)
            throw error
        } catch {
            isLoading = false
            print("Failed to login", error.localizedDescription)
            throw error
        }
    }
    
    private func loginUserToFirebase(email: String, password: String, user: KBUser) async throws {
        let res = try await KBFBManager.shared.auth.signIn(withEmail: email, password: password)
//        KBFBManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
//            if let err = err {
//                print("Failed to login user:", err)
////                self.loginStatusMessage = "Failed to login user: \(err)"
//                return
//            }
//            
//            print("Successfully logged in as user: \(result?.user.uid ?? "")")
//            
//            self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
//            
//            self.didCompleteLoginProcess()
//        }
    }
    
    func registerNewUser(_ model: SignUpModel) async throws -> KBUser {
        // TODO: Do some minor validation
        isLoading = true
        do {
            let response: KBUserData = try await NetworkClient.shared.post(.register, content: model)
            LocalStorage.setString(response.token, for: .userToken)

            try await registerUserToFirebase(
                model.email,
                password: model.password,
                user: response.data
            )
            isLoading = false
            print("Register success", response.data.username)
            return response.data
        } catch let error as APIError {
            isLoading = false
            print("Failed to register, Internal Error:", error.message)
            throw error
        } catch {
            isLoading = false
            print("Failed to register", error.localizedDescription)
            throw error
        }
    }
    
    private func registerUserToFirebase(
        _ email: String,
        password: String,
        user: KBUser
    ) async throws {
        let result = try await KBFBManager.shared.auth.createUser(withEmail: email, password: password)
        let uid = result.user.uid
        let userData: [String: Any?] = [
            FirebaseConstants.uid: uid,
            FirebaseConstants.email: email,
            FirebaseConstants.profilePic: user.profilePic,
            FirebaseConstants.userType: user.role.rawValue,
            FirebaseConstants.username: user.username,
            FirebaseConstants.firstName: user.firstName,
            FirebaseConstants.lastName: user.lastName,
            FirebaseConstants.kbId: user.id.uuidString
        ]
        
        print("Successfully created user")
        
        try await KBFBManager.shared.firestore.collection(FirebaseConstants.users)
            .document(uid)
            .setData(userData.compactMapValues { $0 })
        
        print("Successfully saved user")

//        KBFBManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
//            if let err = err {
//                print("Failed to create user:", err)
//                self.loginStatusMessage = "Failed to create user: \(err)"
//                return
//            }
//            
//            print("Successfully created user: \(result?.user.uid ?? "")")
//            
//            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
//            
//            self.persistImageToStorage()
//        }
    }
    
    func checkUserStatus(_ user: KBUser) async throws -> KBUser.KBAccountStatus {
        guard  user.status != .Approved else {
            return .Approved
        }
        isLoading = true
        do {
            let response: KBUser = try await NetworkClient.shared.get(.getuser(id: user.id))
            
            isLoading = false
            
            if response.status == .Approved {
                try LocalStorage.saveSessionUser(response)
            }
            
            print("Check Status success", response.username)
            return response.status
        } catch let error as APIError {
            isLoading = false
            print("Failed to check user status, Internal Error:", error.message)
            throw error
        } catch {
            isLoading = false
            print("Failed to check user status", error.localizedDescription)
            throw error
        }
    }
}
