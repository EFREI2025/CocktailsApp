//
//  ReviewsListView.swift
//  CocktailsApp
//
//  Created by Georgy GUEI on 12/19/25.
//

import SwiftUI

struct ReviewsListView: View {
    let cocktail: Cocktail
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel: ReviewListViewModel
    @State private var showRatingSheet = false
    
    init(cocktail: Cocktail) {
        self.cocktail = cocktail
        _viewModel = StateObject(wrappedValue: ReviewListViewModel(cocktailId: cocktail.id))
    }
    
    var userReview: Review? {
        guard let userId = authManager.currentUser?.id else { return nil }
        return viewModel.reviews.first(where: { $0.review.authorId == userId })?.review
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Rating Summary
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(viewModel.averageRating.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", viewModel.averageRating) : String(format: "%.1f", viewModel.averageRating))
                                .font(.system(size: 36, weight: .bold))
                            Text("/5")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        
                        if viewModel.reviewCount > 0 {
                            Text("Based on \(viewModel.reviewCount) Review\(viewModel.reviewCount != 1 ? "s" : "")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 4) {
                                ForEach(0..<5) { index in
                                    Image(systemName: index < Int(viewModel.averageRating.rounded()) ? "star.fill" : (index < Int(viewModel.averageRating.rounded(.up)) ? "star.leadinghalf.filled" : "star"))
                                        .foregroundColor(.orange)
                                        .font(.system(size: 20))
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Reviews List
                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding(.vertical, 40)
                    } else if viewModel.reviews.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "text.bubble")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("No reviews yet")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Be the first to review this cocktail!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(viewModel.reviews, id: \.review.id) { reviewWithAuthor in
                                ReviewCard(reviewWithAuthor: reviewWithAuthor)
                            }
                        }
                    }
                    
                    // Rate Button
                    if authManager.isAuthenticated {
                        Button(action: { showRatingSheet = true }) {
                            Text(userReview != nil ? "Edit Your Review" : "Rate This Cocktail")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.accentColor)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Reviews")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showRatingSheet) {
            RatingView(cocktail: cocktail, existingReview: userReview) { newRating in
                Task {
                    await viewModel.refresh()
                }
            }
        }
        .task {
            await viewModel.loadReviews()
        }
    }
}

// MARK: - Review Card
struct ReviewCard: View {
    let reviewWithAuthor: ReviewWithAuthor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(reviewWithAuthor.authorName ?? reviewWithAuthor.authorEmail)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < reviewWithAuthor.review.rating ? "star.fill" : "star")
                                .foregroundColor(.orange)
                                .font(.system(size: 12))
                        }
                    }
                }
                
                Spacer()
                
                Text(timeAgoString(from: reviewWithAuthor.review.createdAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !reviewWithAuthor.review.comment.isEmpty {
                Text(reviewWithAuthor.review.comment)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func timeAgoString(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Rating View
struct RatingView: View {
    let cocktail: Cocktail
    let existingReview: Review?
    let onRatingSubmitted: (Int) -> Void
    
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: ReviewViewModel
    
    init(cocktail: Cocktail, existingReview: Review?, onRatingSubmitted: @escaping (Int) -> Void) {
        self.cocktail = cocktail
        self.existingReview = existingReview
        self.onRatingSubmitted = onRatingSubmitted
        _viewModel = StateObject(wrappedValue: ReviewViewModel(cocktailId: cocktail.id, existingReview: existingReview))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Cocktail Info
                        VStack(spacing: 8) {
                            if let imageURL = cocktail.imageURL {
                                AsyncImage(url: imageURL) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                }
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            Text(cocktail.title)
                                .font(.headline)
                        }
                        .padding(.top, 32)
                        
                        // Star Rating
                        VStack(spacing: 12) {
                            Text("Tap to rate")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 12) {
                                ForEach(1...5, id: \.self) { star in
                                    Button(action: {
                                        viewModel.rating = star
                                    }) {
                                        Image(systemName: star <= viewModel.rating ? "star.fill" : "star")
                                            .font(.system(size: 40))
                                            .foregroundColor(star <= viewModel.rating ? .yellow : .gray.opacity(0.3))
                                    }
                                }
                            }
                        }
                        
                        // Comment
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Add a comment")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextEditor(text: $viewModel.comment)
                                .frame(height: 120)
                                .padding(8)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
                        // Error Message
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding()
                        }
                        
                        // Submit Button
                        Button(action: submitReview) {
                            if viewModel.isSubmitting {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Submit Review")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(viewModel.canSubmit ? Color.accentColor : Color.gray.opacity(0.3))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .disabled(!viewModel.canSubmit || viewModel.isSubmitting)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle(existingReview != nil ? "Edit Review" : "Rate Cocktail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func submitReview() {
        Task {
            let success = await viewModel.submitReview()
            if success {
                onRatingSubmitted(viewModel.rating)
                dismiss()
            }
        }
    }
}
