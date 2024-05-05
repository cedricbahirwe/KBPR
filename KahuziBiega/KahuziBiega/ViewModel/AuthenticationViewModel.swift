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
    
    
    func login(model: SignInScreen.LoginModel) async -> Bool {
        isLoading = true
        do {
            let response: KBUserData = try await NetworkClient.shared.post(.login, content: model)
            
            isLoading = false
            print("Login success", response.data.username)
            return true
        } catch let error as APIError {
            isLoading = false
            print("Failed to login, Internal Error:", error.message)
            return false
        } catch {
            isLoading = false
            print("Failed to login", error.localizedDescription)
            return false
        }
    }
    
    func signup(_ model: SignUpModel) async -> Bool {
        // TODO: Do some minor validation
        isLoading = true
        do {
            let response: KBUserData = try await NetworkClient.shared.post(.register, content: model)
            
            isLoading = false
            print("Register success", response.data.username)
            return true
        } catch let error as APIError {
            isLoading = false
            print("Failed to register, Internal Error:", error.message)
            return false
        } catch {
            isLoading = false
            print("Failed to register", error.localizedDescription)
            return false
        }
    }
}
