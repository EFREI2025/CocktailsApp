//
//  LoginViewModel.swift
//  CocktailsApp
//
//  Created by Georgy GUEI on 12/19/25.
//

import SwiftUI

/// Manages unified login/register authentication
@MainActor
class LoginViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showSuccess = false
    
    private let authManager: AuthManager
    
    init(authManager: AuthManager) {
        self.authManager = authManager
    }
    
    convenience init() {
        self.init(authManager: .shared)
    }
    
    // MARK: - Computed Properties
    
    var canSubmit: Bool {
        !email.isEmpty && !password.isEmpty && password.count >= 6
    }
    
    // MARK: - Actions
    
    /// Login user, or create account if user doesn't exist
    func authenticate() async -> Bool {
        guard canSubmit else {
            if password.count < 6 {
                errorMessage = "Password must be at least 6 characters"
            } else {
                errorMessage = "Please enter email and password"
            }
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Try to login first
            try await authManager.login(email: email, password: password)
            showSuccess = true
            clearForm()
            isLoading = false
            return true
        } catch AuthError.invalidCredentials {
            // If login fails, try to create new account
            do {
                try await authManager.register(email: email, password: password, name: nil)
                showSuccess = true
                clearForm()
                isLoading = false
                return true
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
                return false
            }
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    /// Clear form
    func clearForm() {
        email = ""
        password = ""
        errorMessage = nil
    }
}
