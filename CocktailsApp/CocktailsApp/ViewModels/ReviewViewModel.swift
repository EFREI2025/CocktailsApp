//
//  ReviewViewModel.swift
//  CocktailsApp
//
//  Created by Georgy GUEI on 12/19/25.
//

import SwiftUI

/// Manages review creation and display
@MainActor
class ReviewViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var rating: Int = 5
    @Published var comment: String = ""
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    @Published var showSuccess = false
    
    private let apiService: CocktailAPIService
    private let authManager: AuthManager
    let cocktailId: String
    private(set) var existingReview: Review?
    
    init(cocktailId: String, existingReview: Review? = nil, apiService: CocktailAPIService, authManager: AuthManager) {
        self.cocktailId = cocktailId
        self.existingReview = existingReview
        self.apiService = apiService
        self.authManager = authManager
        
        // Pre-populate with existing review data
        if let review = existingReview {
            self.rating = review.rating
            self.comment = review.comment
        }
    }
    
    convenience init(cocktailId: String, existingReview: Review? = nil) {
        self.init(cocktailId: cocktailId, existingReview: existingReview, apiService: .shared, authManager: .shared)
    }
    
    // MARK: - Computed Properties
    
    var canSubmit: Bool {
        authManager.isAuthenticated && 
        !comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        rating >= 1 && rating <= 5
    }
    
    // MARK: - Actions
    
    /// Submit review (creates new or updates existing)
    func submitReview() async -> Bool {
        guard let userId = authManager.currentUser?.id else {
            errorMessage = "You must be logged in to submit a review"
            return false
        }
        
        guard canSubmit else {
            errorMessage = "Please provide a rating and comment"
            return false
        }
        
        isSubmitting = true
        errorMessage = nil
        
        do {
            if let existing = existingReview {
                // Update existing review
                let updatedReview = Review(
                    id: existing.id,
                    drinkId: cocktailId,
                    authorId: userId,
                    rating: rating,
                    comment: comment.trimmingCharacters(in: .whitespacesAndNewlines),
                    createdAt: existing.createdAt
                )
                _ = try await apiService.updateReview(id: existing.id, review: updatedReview)
            } else {
                // Create new review
                let timestamp = Date().timeIntervalSince1970 * 1000
                let reviewId = "rev\(UUID().uuidString.prefix(4))"
                
                let review = Review(
                    id: reviewId,
                    drinkId: cocktailId,
                    authorId: userId,
                    rating: rating,
                    comment: comment.trimmingCharacters(in: .whitespacesAndNewlines),
                    createdAt: timestamp
                )
                _ = try await apiService.createReview(review: review)
            }
            
            showSuccess = true
            resetForm()
            isSubmitting = false
            return true
        } catch {
            errorMessage = "Failed to submit review: \(error.localizedDescription)"
            isSubmitting = false
            return false
        }
    }
    
    /// Reset form
    func resetForm() {
        rating = 5
        comment = ""
        errorMessage = nil
    }
}

// MARK: - Review List ViewModel
@MainActor
class ReviewListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var reviews: [ReviewWithAuthor] = []
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
    
    var averageRating: Double {
        guard !reviews.isEmpty else { return 0.0 }
        let sum = reviews.reduce(0) { $0 + $1.review.rating }
        return Double(sum) / Double(reviews.count)
    }
    
    // MARK: - Actions
    
    /// Load reviews
    func loadReviews() async {
        isLoading = true
        errorMessage = nil
        
        do {
            reviews = try await apiService.fetchReviewsWithAuthors(forDrinkId: cocktailId)
        } catch {
            errorMessage = "Failed to load reviews: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Delete review (only if current user is author)
    func deleteReview(_ review: Review) async {
        guard let userId = authManager.currentUser?.id,
              review.authorId == userId else {
            errorMessage = "You can only delete your own reviews"
            return
        }
        
        do {
            try await apiService.deleteReview(id: review.id)
            reviews.removeAll { $0.review.id == review.id }
        } catch {
            errorMessage = "Failed to delete review: \(error.localizedDescription)"
        }
    }
    
    /// Check if current user can delete a review
    func canDelete(_ review: Review) -> Bool {
        guard let userId = authManager.currentUser?.id else { return false }
        return review.authorId == userId
    }
    
    /// Refresh reviews
    func refresh() async {
        await loadReviews()
    }
}
