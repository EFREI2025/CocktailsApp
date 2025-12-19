//
//  CocktailDetailViewModel.swift
//  CocktailsApp
//
//  Created by Georgy GUEI on 12/19/25.
//

import SwiftUI

/// Manages single cocktail details with reviews
@MainActor
class CocktailDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var cocktail: Cocktail?
    @Published var reviews: [ReviewWithAuthor] = []
    @Published var averageRating: Double = 0.0
    @Published var isBookmarked = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService: CocktailAPIService
    private let authManager: AuthManager
    let cocktailId: String
    
    init(cocktailId: String, apiService: CocktailAPIService, authManager: AuthManager) {
        self.cocktailId = cocktailId
        self.apiService = apiService
        self.authManager = authManager
    }
    
    convenience init(cocktailId: String) {
        self.init(cocktailId: cocktailId, apiService: .shared, authManager: .shared)
    }
    
    // MARK: - Computed Properties
    
    var reviewCount: Int {
        reviews.count
    }
    
    var canAddReview: Bool {
        authManager.isAuthenticated
    }
    
    // MARK: - Actions
    
    /// Load cocktail details, reviews, and bookmark status
    func loadDetails() async {
        isLoading = true
        errorMessage = nil
        
        await loadCocktail()
        await loadReviews()
        await loadAverageRating()
        
        checkBookmarkStatus()
        
        isLoading = false
    }
    
    /// Load cocktail data
    private func loadCocktail() async {
        do {
            cocktail = try await apiService.fetchCocktail(id: cocktailId)
        } catch {
            errorMessage = "Failed to load cocktail: \(error.localizedDescription)"
        }
    }
    
    /// Load reviews with author information
    private func loadReviews() async {
        do {
            reviews = try await apiService.fetchReviewsWithAuthors(forDrinkId: cocktailId)
        } catch {
            // Non-critical error, just log it
            print("Failed to load reviews: \(error.localizedDescription)")
        }
    }
    
    /// Calculate average rating
    private func loadAverageRating() async {
        do {
            averageRating = try await apiService.calculateAverageRating(forDrinkId: cocktailId)
        } catch {
            // Non-critical error
            averageRating = 0.0
        }
    }
    
    /// Check if current user has bookmarked this cocktail
    private func checkBookmarkStatus() {
        isBookmarked = authManager.isBookmarked(drinkId: cocktailId)
    }
    
    /// Toggle bookmark status
    func toggleBookmark() async {
        guard authManager.isAuthenticated else {
            errorMessage = "Please login to bookmark cocktails"
            return
        }
        
        do {
            if isBookmarked {
                try await authManager.removeBookmark(drinkId: cocktailId)
                isBookmarked = false
            } else {
                try await authManager.addBookmark(drinkId: cocktailId)
                isBookmarked = true
            }
        } catch {
            errorMessage = "Failed to update bookmark: \(error.localizedDescription)"
        }
    }
    
    /// Refresh all data
    func refresh() async {
        await loadDetails()
    }
}
