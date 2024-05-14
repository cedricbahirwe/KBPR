//
//  AuthenticationViewModel.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 05/05/2024.
//

import Foundation


// TODO: - Improve printing to be helpful fast

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var isLoading = false
//    @Published var isLoggedIn = false
    
    
    func login(model: SignInScreen.LoginModel) async throws -> KBUser {
        isLoading = true
        do {
            let response: KBUserData = try await NetworkClient.shared.post(.login, content: model)
            
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
    
    func registerNewUser(_ model: SignUpModel) async throws -> KBUser {
        // TODO: Do some minor validation
        isLoading = true
        do {
            let response: KBUserData = try await NetworkClient.shared.post(.register, content: model)
            
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
    
    func checkUserStatus(_ user: KBUser) async throws -> KBUser.KBAccountStatus {
        guard  user.status != .Approved else {
            return .Approved
        }
        isLoading = true
        do {
            let response: KBUserData = try await NetworkClient.shared.get(.getuser(id: user.id))
            
            isLoading = false
            print("Check Status success", response.data.username)
            return response.data.status
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
