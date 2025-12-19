//
//  BookmarksView.swift
//  CocktailsApp
//
//  Created by Georgy GUEI on 12/19/25.
//

import SwiftUI

struct BookmarksView: View {
    @StateObject private var viewModel = BookmarksViewModel()
    @EnvironmentObject var authManager: AuthManager
    @State private var showLoginSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                if !authManager.isAuthenticated {
                    // Not logged in state
                    VStack(spacing: 20) {
                        Image(systemName: "person.crop.circle.badge.xmark")
                            .font(.system(size: 70))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Login Required")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Please login to view your bookmarked cocktails")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: { showLoginSheet = true }) {
                            Text("Login")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: 200)
                                .padding(.vertical, 14)
                                .background(Color.accentColor)
                                .cornerRadius(12)
                        }
                    }
                } else if viewModel.isLoading {
                    // Loading state
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading bookmarks...")
                            .foregroundColor(.secondary)
                    }
                } else if let error = viewModel.errorMessage {
                    // Error state
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 60))
                            .foregroundColor(.red.opacity(0.5))
                        Text("Error Loading Bookmarks")
                            .font(.headline)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Retry") {
                            Task {
                                await viewModel.loadBookmarks()
                            }
                        }
                        .foregroundColor(.accentColor)
                    }
                } else if viewModel.bookmarkedCocktails.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "bookmark.slash")
                            .font(.system(size: 70))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No Bookmarks Yet")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Start bookmarking your favorite cocktails to see them here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    // Bookmarks list
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(viewModel.bookmarkedCocktails) { cocktail in
                                NavigationLink(destination: CocktailDetailView(cocktail: cocktail)) {
                                    BookmarkCard(cocktail: cocktail) {
                                        Task {
                                            await viewModel.removeBookmark(cocktail)
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle("Bookmarks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if authManager.isAuthenticated && !viewModel.bookmarkedCocktails.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Text("\(viewModel.bookmarkCount)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showLoginSheet) {
                LoginView()
            }
        }
        .task {
            if authManager.isAuthenticated {
                await viewModel.loadBookmarks()
            }
        }
        .onChange(of: authManager.isAuthenticated) { oldValue, newValue in
            if newValue {
                Task {
                    await viewModel.loadBookmarks()
                }
            }
        }
    }
}

// MARK: - Bookmark Card
struct BookmarkCard: View {
    let cocktail: Cocktail
    let onRemove: () -> Void
    @State private var averageRating: Double = 0.0
    @State private var showRemoveConfirmation = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Image with rating overlay
            ZStack(alignment: .topLeading) {
                if let imageURL = cocktail.imageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        case .failure:
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .overlay(
                                    Image(systemName: "wineglass")
                                        .font(.system(size: 20))
                                        .foregroundColor(.gray)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 80, height: 80)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "wineglass")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                        )
                }
                
                // Rating badge
                if averageRating > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", averageRating))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(6)
                    .padding(6)
                }
            }
            
            // Info section
            VStack(alignment: .leading, spacing: 3) {
                Text(cocktail.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(cocktail.category)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                // Tags
                if !cocktail.tagsArray.isEmpty {
                    Text(cocktail.tagsArray.prefix(2).joined(separator: " • "))
                        .font(.system(size: 12))
                        .foregroundColor(.accentColor)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Bookmark button
            Button(action: {
                showRemoveConfirmation = true
            }) {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.accentColor)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        .confirmationDialog("Remove Bookmark", isPresented: $showRemoveConfirmation, titleVisibility: .visible) {
            Button("Remove", role: .destructive) {
                onRemove()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to remove \"\(cocktail.title)\" from your bookmarks?")
        }
        .onAppear {
            Task {
                await loadAverageRating()
            }
        }
    }
    
    private func loadAverageRating() async {
        do {
            let rating = try await CocktailAPIService.shared.calculateAverageRating(forDrinkId: cocktail.id)
            averageRating = rating
        } catch {
            averageRating = 0.0
        }
    }
}

#Preview {
    BookmarksView()
        .environmentObject(AuthManager.shared)
}
