//
//  CocktailDetailView.swift
//  CocktailsApp
//
//  Created by Georgy GUEI on 12/19/25.
//

import SwiftUI

struct CocktailDetailView: View {
    let cocktail: Cocktail
    @EnvironmentObject var authManager: AuthManager
    @State private var isBookmarked = false
    @State private var averageRating: Double = 0.0
    @State private var reviewCount = 0
    @State private var ratingDistribution: [Int: Int] = [:]
    @State private var isLoadingReviews = false
    @State private var showIngredientsExpanded = false
    @State private var showInstructionsExpanded = true
    @State private var isDescriptionExpanded = false
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero Image
                    if let imageURL = cocktail.imageURL {
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .overlay(ProgressView())
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .overlay(
                                        Image(systemName: "wineglass")
                                            .font(.system(size: 60))
                                            .foregroundColor(.gray)
                                    )
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(height: 300)
                        .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 300)
                            .overlay(
                                Image(systemName: "wineglass")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                            )
                    }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    // Content
                    VStack(alignment: .leading, spacing: 24) {
                        // Category Badge and Rating
                        HStack {
                            Text(cocktail.category)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 14))
                                Text(averageRating.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", averageRating) : String(format: "%.1f", averageRating))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        // Title
                        Text(cocktail.title)
                            .font(.system(size: 28, weight: .bold))
                        
                        // Description
                        if let description = cocktail.description, !description.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(description)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .lineSpacing(4)
                                    .lineLimit(isDescriptionExpanded ? nil : 4)
                                
                                if !isDescriptionExpanded {
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            isDescriptionExpanded = true
                                        }
                                    }) {
                                        Text("more")
                                            .font(.body)
                                            .foregroundColor(.accentColor)
                                    }
                                }
                            }
                        }
                        
                        // Info Cards Grid (2x2)
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            if let prepTime = cocktail.prepTime {
                                InfoCard(icon: "clock.fill", iconColor: .accentColor, title: "Cooking Time", value: prepTime)
                            }
                            
                            if let glass = cocktail.glass {
                                InfoCard(icon: "wineglass.fill", iconColor: .accentColor, title: "Glass", value: glass)
                            }
                            
                            if let alcoholContent = cocktail.alcoholContent {
                                InfoCard(icon: "drop.fill", iconColor: .accentColor, title: "Alcohol", value: alcoholContent.capitalized)
                            }
                            
                            if let difficulty = cocktail.difficulty {
                                InfoCard(icon: "chart.bar.fill", iconColor: .accentColor, title: "Difficulty", value: difficulty.capitalized)
                            }
                        }
                        
                        // Ingredients Section (Collapsible)
                        VStack(spacing: 0) {
                            Button(action: { 
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showIngredientsExpanded.toggle()
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "list.bullet")
                                        .foregroundColor(.accentColor)
                                        .font(.system(size: 18))
                                    
                                    Text("Ingredients")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    if let servings = cocktail.servings {
                                        Text("\(servings) Serving")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Image(systemName: showIngredientsExpanded ? "chevron.up" : "chevron.down")
                                        .foregroundColor(.secondary)
                                        .rotationEffect(.degrees(showIngredientsExpanded ? 0 : 180))
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if showIngredientsExpanded {
                                VStack(spacing: 12) {
                                    ForEach(Array(cocktail.ingredients.enumerated()), id: \.offset) { index, ingredient in
                                        HStack(alignment: .top, spacing: 12) {
                                            Circle()
                                                .fill(Color.accentColor)
                                                .frame(width: 6, height: 6)
                                                .padding(.top, 7)
                                            
                                            Text(ingredient)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.separator), lineWidth: 0.5)
                        )
                        
                        // Instructions Section (Collapsible)
                        if let instructions = cocktail.instructions, !instructions.isEmpty {
                            VStack(spacing: 0) {
                                Button(action: { 
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showInstructionsExpanded.toggle()
                                    }
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "doc.text")
                                            .foregroundColor(.accentColor)
                                            .font(.system(size: 18))
                                        
                                        Text("Instructions")
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: showInstructionsExpanded ? "chevron.up" : "chevron.down")
                                            .foregroundColor(.secondary)
                                            .rotationEffect(.degrees(showInstructionsExpanded ? 0 : 180))
                                    }
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                if showInstructionsExpanded {
                                    Text(instructions)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .lineSpacing(4)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background(Color(.secondarySystemBackground))
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.separator), lineWidth: 0.5)
                            )
                        }
                        
                        // Rating Breakdown Section
                        if reviewCount > 0 {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text(averageRating.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", averageRating) : String(format: "%.1f", averageRating))
                                        .font(.system(size: 36, weight: .bold))
                                    Text("/5")
                                        .font(.system(size: 16))
                                        .foregroundColor(.secondary)
                                }
                                
                                Text("Based on \(reviewCount) Review\(reviewCount != 1 ? "s" : "")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                // Star rating display
                                HStack(spacing: 4) {
                                    ForEach(0..<5) { index in
                                        let starValue = Double(index) + 1.0
                                        Image(systemName: 
                                            averageRating >= starValue ? "star.fill" : 
                                            (averageRating >= starValue - 0.5 ? "star.leadinghalf.filled" : "star")
                                        )
                                        .foregroundColor(.orange)
                                        .font(.system(size: 20))
                                    }
                                }
                                
                                // Rating distribution bars
                                VStack(spacing: 8) {
                                    ForEach((1...5).reversed(), id: \.self) { star in
                                        RatingDistributionBar(
                                            stars: star,
                                            count: ratingDistribution[star] ?? 0,
                                            total: reviewCount
                                        )
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                        }
                        
                        // Reviews Navigation Button
                        NavigationLink(destination: ReviewsListView(cocktail: cocktail)) {
                            HStack(spacing: 12) {
                                Image(systemName: "text.bubble")
                                    .foregroundColor(.accentColor)
                                    .font(.system(size: 18))
                                
                                Text("Reviews")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 14))
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.separator), lineWidth: 0.5)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .offset(y: -20)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Task {
                        await toggleBookmark()
                    }
                }) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 20))
                        .foregroundColor(isBookmarked ? .accentColor : .primary)
                }
            }
        }
        .task {
            checkBookmarkStatus()
            await loadRatingAndReviews()
        }
    }
    
    // MARK: - Helper Functions
    
    private func checkBookmarkStatus() {
        isBookmarked = authManager.isBookmarked(drinkId: cocktail.id)
    }
    
    private func toggleBookmark() async {
        guard authManager.isAuthenticated else { return }
        
        do {
            if isBookmarked {
                try await authManager.removeBookmark(drinkId: cocktail.id)
                isBookmarked = false
            } else {
                try await authManager.addBookmark(drinkId: cocktail.id)
                isBookmarked = true
            }
        } catch {
            print("Failed to toggle bookmark: \(error)")
        }
    }
    
    private func loadRatingAndReviews() async {
        isLoadingReviews = true
        
        do {
            // Load basic rating info
            averageRating = try await CocktailAPIService.shared.calculateAverageRating(forDrinkId: cocktail.id)
            let reviews = try await CocktailAPIService.shared.fetchReviews(forDrinkId: cocktail.id)
            reviewCount = reviews.count
            
            // Calculate rating distribution
            ratingDistribution = [:]
            for review in reviews {
                ratingDistribution[review.rating, default: 0] += 1
            }
        } catch {
            print("Failed to load reviews: \(error)")
        }
        
        isLoadingReviews = false
    }
}

// MARK: - Info Card
struct InfoCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Icon with circular background
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 20))
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text(value)
                    .font(.headline)
                    .foregroundColor(iconColor)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Rating Distribution Bar
struct RatingDistributionBar: View {
    let stars: Int
    let count: Int
    let total: Int
    
    var percentage: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(count) / CGFloat(total)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(stars) Star")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: geometry.size.width * percentage, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            
            Text("\(count)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 20, alignment: .trailing)
        }
    }
}

#Preview {
    NavigationView {
        CocktailDetailView(cocktail: Cocktail(
            id: "1",
            title: "Mojito",
            description: "A refreshing Cuban cocktail",
            category: "Cocktail",
            type: "drink",
            glass: "Highball",
            instructions: "Muddle mint and sugar...",
            ingredients: ["White rum", "Sugar", "Lime juice", "Soda water", "Mint"],
            imageSource: nil,
            imageAlt: nil,
            tags: ["Refreshing", "Mint", "Summer"],
            difficulty: "easy",
            prepTime: "5 min",
            servings: 1,
            alcoholContent: "medium",
            createdAt: Date().timeIntervalSince1970,
            updatedAt: Date().timeIntervalSince1970
        ))
        .environmentObject(AuthManager.shared)
    }
}
