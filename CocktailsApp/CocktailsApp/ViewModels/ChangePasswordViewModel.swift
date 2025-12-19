//
//  ChangePasswordViewModel.swift
//  CocktailsApp
//
//  Created by Georgy GUEI on 12/19/25.
//

import SwiftUI

/// Manages password change functionality
@MainActor
class ChangePasswordViewModel: ObservableObject {
    @Published var currentPassword = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
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
    
    // MARK: - Validation
    
    var canSubmit: Bool {
        !currentPassword.isEmpty &&
        !newPassword.isEmpty &&
        !confirmPassword.isEmpty &&
        newPassword.count >= 6 &&
        newPassword == confirmPassword
    }
    
    var passwordsMatch: Bool {
        confirmPassword.isEmpty || newPassword == confirmPassword
    }
    
    // MARK: - Actions
    
    func changePassword() async -> Bool {
        guard canSubmit else {
            errorMessage = "Please fill all fields correctly"
            return false
        }
        
        guard let user = authManager.currentUser else {
            errorMessage = "User not authenticated"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // First verify current password by attempting login
            _ = try await CocktailAPIService.shared.loginUser(email: user.email, password: currentPassword)
            
            // Update password
            let updatedUser = User(
                id: user.id,
                email: user.email,
                password: newPassword,
                createdAt: user.createdAt,
                updatedAt: Date().timeIntervalSince1970,
                name: user.name,
                dateOfBirth: user.dateOfBirth,
                phone: user.phone,
                gender: user.gender,
                bookmarks: user.bookmarks
            )
            
            // Send update request to API
            _ = try await CocktailAPIService.shared.updateUser(id: user.id, user: updatedUser)
            
            showSuccess = true
            isLoading = false
            
            // Clear fields
            currentPassword = ""
            newPassword = ""
            confirmPassword = ""
            
            return true
        } catch {
            isLoading = false
            if error.localizedDescription.contains("401") || error.localizedDescription.contains("Invalid") {
                errorMessage = "Current password is incorrect"
            } else {
                errorMessage = "Failed to change password: \(error.localizedDescription)"
            }
            return false
        }
    }
    
    func clearForm() {
        currentPassword = ""
        newPassword = ""
        confirmPassword = ""
        errorMessage = nil
        showSuccess = false
    }
}
