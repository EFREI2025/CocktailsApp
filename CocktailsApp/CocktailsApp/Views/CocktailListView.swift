//
//  CocktailListView.swift
//  CocktailsApp
//
//  Created by Georgy GUEI on 12/19/25.
//

import SwiftUI

struct CocktailListView: View {
    @StateObject private var viewModel = CocktailListViewModel()
    @EnvironmentObject var authManager: AuthManager
    @State private var showFilterSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            TextField("Search cocktails...", text: $viewModel.searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                            
                            if !viewModel.searchText.isEmpty {
                                Button(action: { viewModel.searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(12)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        
                        Button(action: { showFilterSheet = true }) {
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding()
                    
                    // Active Filters Chips
                    if hasActiveFilters {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                if let category = viewModel.selectedCategory {
                                    FilterChip(title: category) {
                                        viewModel.selectedCategory = nil
                                    }
                                }
                                
                                if let difficulty = viewModel.selectedDifficulty {
                                    FilterChip(title: difficulty.rawValue.capitalized) {
                                        viewModel.selectedDifficulty = nil
                                    }
                                }
                                
                                if let alcohol = viewModel.selectedAlcoholLevel {
                                    FilterChip(title: alcohol.rawValue.capitalized) {
                                        viewModel.selectedAlcoholLevel = nil
                                    }
                                }
                                
                                ForEach(Array(viewModel.selectedTags), id: \.self) { tag in
                                    FilterChip(title: tag) {
                                        viewModel.toggleTag(tag)
                                    }
                                }
                                
                                Button(action: { viewModel.resetFilters() }) {
                                    Text("Clear All")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.red.opacity(0.1))
                                        .cornerRadius(16)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 8)
                    }
                    
                    // Cocktail Grid
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else if let error = viewModel.errorMessage {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 60))
                                .foregroundColor(.red.opacity(0.5))
                            Text("Error Loading Cocktails")
                                .font(.headline)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Button("Retry") {
                                Task {
                                    await viewModel.loadCocktails()
                                }
                            }
                            .foregroundColor(.accentColor)
                        }
                        Spacer()
                    } else if viewModel.filteredCocktails.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "wineglass")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("No cocktails found")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            if hasActiveFilters {
                                Button("Clear Filters") {
                                    viewModel.resetFilters()
                                }
                                .foregroundColor(.accentColor)
                            }
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 16) {
                                ForEach(viewModel.filteredCocktails) { cocktail in
                                    NavigationLink(destination: CocktailDetailView(cocktail: cocktail)) {
                                        CocktailCard(cocktail: cocktail)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                        }
                        .refreshable {
                            await viewModel.refresh()
                        }
                    }
                }
            }
            .navigationTitle("Cocktails")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showFilterSheet) {
                FilterView(viewModel: viewModel)
            }
        }
        .task {
            await viewModel.loadCocktails()
        }
    }
    
    var hasActiveFilters: Bool {
        viewModel.selectedCategory != nil ||
        viewModel.selectedDifficulty != nil ||
        viewModel.selectedAlcoholLevel != nil ||
        !viewModel.selectedTags.isEmpty
    }
}

// MARK: - Cocktail Card
struct CocktailCard: View {
    let cocktail: Cocktail
    @EnvironmentObject var authManager: AuthManager
    @State private var isBookmarked = false
    @State private var averageRating: Double = 0.0
    @State private var isLoadingRating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image with overlays
            ZStack(alignment: .topLeading) {
                // Image
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
                                        .foregroundColor(.gray)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(height: 140)
                    .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 140)
                        .overlay(
                            Image(systemName: "wineglass")
                                .foregroundColor(.gray)
                        )
                }
                
                // Top overlay elements
                HStack {
                    // Rating badge (top left) - only show if there's a rating
                    if averageRating > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", averageRating))
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                        .padding(8)
                    }
                    
                    Spacer()
                    
                    // Bookmark button (top right)
                    Button(action: {
                        Task {
                            await toggleBookmark()
                        }
                    }) {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 16))
                            .foregroundColor(isBookmarked ? .accentColor : .white)
                            .padding(8)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding(8)
                }
            }
            .cornerRadius(12)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(cocktail.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(cocktail.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Tags
                if !cocktail.tagsArray.isEmpty {
                    Text(cocktail.tagsArray.prefix(2).joined(separator: " • "))
                        .font(.caption2)
                        .foregroundColor(.accentColor)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        .onAppear {
            checkBookmarkStatus()
            Task {
                await loadAverageRating()
            }
        }
    }
    
    private func checkBookmarkStatus() {
        isBookmarked = authManager.isBookmarked(drinkId: cocktail.id)
    }
    
    private func loadAverageRating() async {
        guard !isLoadingRating else { return }
        isLoadingRating = true
        
        do {
            let rating = try await CocktailAPIService.shared.calculateAverageRating(forDrinkId: cocktail.id)
            averageRating = rating
        } catch {
            // Silently fail - just don't show rating
            averageRating = 0.0
        }
        
        isLoadingRating = false
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
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.accentColor)
        .cornerRadius(16)
    }
}

// MARK: - Filter View
struct FilterView: View {
    @ObservedObject var viewModel: CocktailListViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Category Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(viewModel.availableCategories, id: \.self) { category in
                                SelectableChip(
                                    title: category,
                                    isSelected: viewModel.selectedCategory == category
                                ) {
                                    viewModel.selectedCategory = viewModel.selectedCategory == category ? nil : category
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Difficulty Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Difficulty")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        FlowLayout(spacing: 8) {
                            ForEach([DifficultyLevel.easy, .medium, .hard], id: \.self) { difficulty in
                                SelectableChip(
                                    title: difficulty.rawValue.capitalized,
                                    isSelected: viewModel.selectedDifficulty == difficulty
                                ) {
                                    viewModel.selectedDifficulty = viewModel.selectedDifficulty == difficulty ? nil : difficulty
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Alcohol Level Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Alcohol Content")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        FlowLayout(spacing: 8) {
                            ForEach([AlcoholLevel.none, .low, .medium, .high, .veryHigh], id: \.self) { level in
                                SelectableChip(
                                    title: level.rawValue.capitalized,
                                    isSelected: viewModel.selectedAlcoholLevel == level
                                ) {
                                    viewModel.selectedAlcoholLevel = viewModel.selectedAlcoholLevel == level ? nil : level
                                }
                            }
                        }
                    }
                    
                    // Tags Section
                    if !viewModel.availableTags.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tags")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(viewModel.availableTags, id: \.self) { tag in
                                    SelectableChip(
                                        title: tag,
                                        isSelected: viewModel.selectedTags.contains(tag)
                                    ) {
                                        viewModel.toggleTag(tag)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemBackground))
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        viewModel.resetFilters()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Selectable Chip
struct SelectableChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color(.separator), lineWidth: 1)
                )
        }
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(origin: CGPoint(x: currentX, y: currentY), size: size))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    CocktailListView()
        .environmentObject(AuthManager.shared)
}
