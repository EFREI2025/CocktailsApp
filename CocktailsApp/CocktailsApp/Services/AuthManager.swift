//
//  AuthManager.swift
//  CocktailsApp
//
//  Created by Georgy GUEI on 12/19/25.
//

import Foundation

/// Manages user authentication state
@MainActor
class AuthManager: ObservableObject {
    // Shared instance for convenience
    static let shared = AuthManager()
    
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    
    private let apiService: CocktailAPIService
    
    // UserDefaults keys
    private let userIdKey = "currentUserId"
    
    init(apiService: CocktailAPIService = .shared) {
        self.apiService = apiService
        loadStoredUser()
    }
    
    // MARK: - Authentication
    
    /// Login with email and password
    func login(email: String, password: String) async throws {
        let users = try await apiService.loginUser(email: email, password: password)
        
        guard let user = users.first else {
            throw AuthError.invalidCredentials
        }
        
        currentUser = user
        isAuthenticated = true
        storeUserId(user.id)
    }
    
    /// Logout current user
    func logout() {
        currentUser = nil
        isAuthenticated = false
        clearStoredUserId()
    }
    
    /// Register new user
    func register(email: String, password: String, name: String? = nil) async throws {
        // Validate email format
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }
        
        // Check if user already exists
        let existingUsers = try await apiService.fetchUser(byEmail: email)
        if !existingUsers.isEmpty {
            throw AuthError.userAlreadyExists
        }
        
        let timestamp = Date().timeIntervalSince1970 * 1000 // milliseconds
        let userId = UUID().uuidString.prefix(4).lowercased()
        
        let newUser = User(
            id: String(userId),
            email: email,
            password: password,
            createdAt: timestamp,
            updatedAt: timestamp,
            name: name,
            dateOfBirth: nil,
            phone: nil,
            gender: nil,
            bookmarks: []
        )
        
        let createdUser = try await apiService.createUser(user: newUser)
        
        currentUser = createdUser
        isAuthenticated = true
        storeUserId(createdUser.id)
    }
    
    /// Update current user profile
    func updateProfile(name: String?, dateOfBirth: String?, phone: String?, gender: String?) async throws {
        guard let user = currentUser else {
            throw AuthError.notAuthenticated
        }
        
        let timestamp = Date().timeIntervalSince1970 * 1000
        
        let updatedUser = User(
            id: user.id,
            email: user.email,
            password: user.password,
            createdAt: user.createdAt,
            updatedAt: timestamp,
            name: name ?? user.name,
            dateOfBirth: dateOfBirth ?? user.dateOfBirth,
            phone: phone ?? user.phone,
            gender: gender ?? user.gender,
            bookmarks: user.bookmarks
        )
        
        let savedUser = try await apiService.updateUser(id: user.id, user: updatedUser)
        currentUser = savedUser
    }
    
    // MARK: - Bookmarks
    
    /// Add bookmark for current user
    func addBookmark(drinkId: String) async throws {
        guard let user = currentUser else {
            throw AuthError.notAuthenticated
        }
        
        let timestamp = Date().timeIntervalSince1970 * 1000
        let bookmarkId = "bm\(UUID().uuidString.prefix(4))"
        
        let bookmark = Bookmark(
            id: bookmarkId,
            userId: user.id,
            drinkId: drinkId,
            createdAt: timestamp
        )
        
        _ = try await apiService.createBookmark(bookmark: bookmark)
        
        // Update local user bookmarks array
        var updatedBookmarks = user.bookmarks ?? []
        if !updatedBookmarks.contains(drinkId) {
            updatedBookmarks.append(drinkId)
            
            let updatedUser = User(
                id: user.id,
                email: user.email,
                password: user.password,
                createdAt: user.createdAt,
                updatedAt: timestamp,
                name: user.name,
                dateOfBirth: user.dateOfBirth,
                phone: user.phone,
                gender: user.gender,
                bookmarks: updatedBookmarks
            )
            
            currentUser = try await apiService.updateUser(id: user.id, user: updatedUser)
        }
    }
    
    /// Remove bookmark for current user
    func removeBookmark(drinkId: String) async throws {
        guard let user = currentUser else {
            throw AuthError.notAuthenticated
        }
        
        // Find and delete the bookmark
        let bookmarks = try await apiService.fetchBookmarks(forUserId: user.id)
        if let bookmark = bookmarks.first(where: { $0.drinkId == drinkId }) {
            try await apiService.deleteBookmark(id: bookmark.id)
        }
        
        // Update local user bookmarks array
        let timestamp = Date().timeIntervalSince1970 * 1000
        var updatedBookmarks = user.bookmarks ?? []
        updatedBookmarks.removeAll { $0 == drinkId }
        
        let updatedUser = User(
            id: user.id,
            email: user.email,
            password: user.password,
            createdAt: user.createdAt,
            updatedAt: timestamp,
            name: user.name,
            dateOfBirth: user.dateOfBirth,
            phone: user.phone,
            gender: user.gender,
            bookmarks: updatedBookmarks
        )
        
        currentUser = try await apiService.updateUser(id: user.id, user: updatedUser)
    }
    
    /// Check if drink is bookmarked by current user
    func isBookmarked(drinkId: String) -> Bool {
        guard let bookmarks = currentUser?.bookmarks else { return false }
        return bookmarks.contains(drinkId)
    }
    
    // MARK: - Persistence
    
    /// Load stored user from UserDefaults on app launch
    private func loadStoredUser() {
        guard let userId = UserDefaults.standard.string(forKey: userIdKey) else {
            return
        }
        
        Task {
            do {
                let user = try await apiService.fetchUser(id: userId)
                currentUser = user
                isAuthenticated = true
            } catch {
                // User not found or network error - clear stored ID
                clearStoredUserId()
            }
        }
    }
    
    private func storeUserId(_ userId: String) {
        UserDefaults.standard.set(userId, forKey: userIdKey)
    }
    
    private func clearStoredUserId() {
        UserDefaults.standard.removeObject(forKey: userIdKey)
    }
    
    // MARK: - Validation
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
    }
}

// MARK: - Auth Errors
enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case notAuthenticated
    case userAlreadyExists
    case invalidEmail
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .notAuthenticated:
            return "User not authenticated"
        case .userAlreadyExists:
            return "User with this email already exists"
        case .invalidEmail:
            return "Invalid email format"
        }
    }
}
