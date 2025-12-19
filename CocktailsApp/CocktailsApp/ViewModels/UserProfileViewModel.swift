//
//  UserProfileViewModel.swift
//  CocktailsApp
//
//  Created by Georgy GUEI on 12/19/25.
//

import SwiftUI

/// Manages user profile viewing and editing
@MainActor
class UserProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var name = ""
    @Published var dateOfBirth = ""
    @Published var phone = ""
    @Published var gender = ""
    @Published var isEditing = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showSuccess = false
    
    private let authManager: AuthManager
    
    init(authManager: AuthManager) {
        self.authManager = authManager
        loadUserData()
    }
    
    convenience init() {
        self.init(authManager: .shared)
    }
    
    // MARK: - Computed Properties
    
    var currentUser: User? {
        authManager.currentUser
    }
    
    var isAuthenticated: Bool {
        authManager.isAuthenticated
    }
    
    var hasChanges: Bool {
        guard let user = currentUser else { return false }
        return name != (user.name ?? "") ||
               dateOfBirth != (user.dateOfBirth ?? "") ||
               phone != (user.phone ?? "") ||
               gender != (user.gender ?? "")
    }
    
    // MARK: - Actions
    
    /// Load user data into form
    func loadUserData() {
        guard let user = currentUser else { return }
        name = user.name ?? ""
        dateOfBirth = user.dateOfBirth ?? ""
        phone = user.phone ?? ""
        gender = user.gender ?? ""
    }
    
    /// Save profile changes
    func saveProfile() async -> Bool {
        guard hasChanges else {
            isEditing = false
            return true
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authManager.updateProfile(
                name: name.isEmpty ? nil : name,
                dateOfBirth: dateOfBirth.isEmpty ? nil : dateOfBirth,
                phone: phone.isEmpty ? nil : phone,
                gender: gender.isEmpty ? nil : gender
            )
            showSuccess = true
            isEditing = false
            isLoading = false
            return true
        } catch {
            errorMessage = "Failed to save profile: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    /// Cancel editing and revert changes
    func cancelEditing() {
        loadUserData()
        isEditing = false
        errorMessage = nil
    }
    
    /// Start editing
    func startEditing() {
        isEditing = true
        errorMessage = nil
    }
    
    /// Logout
    func logout() {
        authManager.logout()
    }
}
