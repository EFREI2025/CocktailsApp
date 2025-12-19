//
//  CocktailListViewModel.swift
//  CocktailsApp
//
//  Created by Georgy GUEI on 12/19/25.
//

import SwiftUI

/// Manages cocktail list browsing and search
@MainActor
class CocktailListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var cocktails: [Cocktail] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Search
    @Published var searchText = ""
    
    // Filters
    @Published var selectedCategory: String?
    @Published var selectedDifficulty: DifficultyLevel?
    @Published var selectedAlcoholLevel: AlcoholLevel?
    @Published var selectedTags: Set<String> = []
    
    private let apiService: CocktailAPIService
    
    init(apiService: CocktailAPIService) {
        self.apiService = apiService
    }
    
    convenience init() {
        self.init(apiService: .shared)
    }
    
    // MARK: - Computed Properties
    
    /// Available categories from loaded cocktails
    var availableCategories: [String] {
        Array(Set(cocktails.map { $0.category })).sorted()
    }
    
    /// All unique tags from loaded cocktails
    var availableTags: [String] {
        let allTags = cocktails.flatMap { $0.tagsArray }
        return Array(Set(allTags)).sorted()
    }
    
    /// Filtered cocktails based on search and filters
    var filteredCocktails: [Cocktail] {
        var results = cocktails
        
        // Search filter
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            results = results.filter { cocktail in
                cocktail.title.lowercased().contains(query) ||
                cocktail.description?.lowercased().contains(query) == true ||
                cocktail.ingredients.contains(where: { $0.lowercased().contains(query) })
            }
        }
        
        // Category filter
        if let category = selectedCategory {
            results = results.filter { $0.category == category }
        }
        
        // Difficulty filter
        if let difficulty = selectedDifficulty {
            results = results.filter { $0.difficultyLevel == difficulty }
        }
        
        // Alcohol level filter
        if let alcoholLevel = selectedAlcoholLevel {
            results = results.filter { $0.alcoholLevel == alcoholLevel }
        }
        
        // Tags filter
        if !selectedTags.isEmpty {
            results = results.filter { cocktail in
                let cocktailTags = Set(cocktail.tagsArray)
                return !selectedTags.isDisjoint(with: cocktailTags)
            }
        }
        
        // Sort by title alphabetically
        return results.sorted { $0.title.lowercased() < $1.title.lowercased() }
    }
    
    // MARK: - Actions
    
    /// Load all cocktails
    func loadCocktails() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedCocktails = try await apiService.fetchCocktails()
            cocktails = fetchedCocktails.sorted { $0.title.lowercased() < $1.title.lowercased() }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Refresh cocktails
    func refresh() async {
        await loadCocktails()
    }
    
    /// Search cocktails with specific query parameters
    func searchCocktails(query: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            cocktails = try await apiService.searchCocktails(query: query)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Reset all filters
    func resetFilters() {
        selectedCategory = nil
        selectedDifficulty = nil
        selectedAlcoholLevel = nil
        selectedTags.removeAll()
        searchText = ""
    }
    
    /// Toggle tag selection
    func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
}
