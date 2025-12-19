//
//  BookmarksViewModel.swift
//  CocktailsApp
//
//  Created by Georgy GUEI on 12/19/25.
//

import SwiftUI

/// Manages user's bookmarked cocktails
@MainActor
class BookmarksViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var bookmarkedCocktails: [Cocktail] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService: CocktailAPIService
    private let authManager: AuthManager
    
    init(apiService: CocktailAPIService, authManager: AuthManager) {
        self.apiService = apiService
        self.authManager = authManager
    }
    
    convenience init() {
        self.init(apiService: .shared, authManager: .shared)
    }
    
    // MARK: - Computed Properties
    
    var hasBookmarks: Bool {
        !bookmarkedCocktails.isEmpty
    }
    
    var bookmarkCount: Int {
        bookmarkedCocktails.count
    }
    
    // MARK: - Actions
    
    /// Load bookmarked cocktails for current user
    func loadBookmarks() async {
        guard let userId = authManager.currentUser?.id else {
            errorMessage = "User not logged in"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch user's bookmarks
            let bookmarks = try await apiService.fetchBookmarks(forUserId: userId)
            
            // Fetch full cocktail details for each bookmark
            var cocktails: [Cocktail] = []
            for bookmark in bookmarks {
                do {
                    let cocktail = try await apiService.fetchCocktail(id: bookmark.drinkId)
                    cocktails.append(cocktail)
                } catch {
                    print("Failed to load cocktail \(bookmark.drinkId): \(error)")
                }
            }
            
            bookmarkedCocktails = cocktails
        } catch {
            errorMessage = "Failed to load bookmarks: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Remove bookmark
    func removeBookmark(_ cocktail: Cocktail) async {
        do {
            try await authManager.removeBookmark(drinkId: cocktail.id)
            bookmarkedCocktails.removeAll { $0.id == cocktail.id }
        } catch {
            errorMessage = "Failed to remove bookmark: \(error.localizedDescription)"
        }
    }
    
    /// Check if cocktail is bookmarked
    func isBookmarked(_ cocktailId: String) -> Bool {
        bookmarkedCocktails.contains { $0.id == cocktailId }
    }
    
    /// Refresh bookmarks
    func refresh() async {
        await loadBookmarks()
    }
}
