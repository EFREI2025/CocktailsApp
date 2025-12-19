//
//  Cocktail.swift
//  CocktailsApp
//
//  Created by Georgy GUEI on 12/19/25.
//

import Foundation

// MARK: - API Response Wrappers
// Wrappers for json-server endpoints (can decode arrays directly as well)
struct CocktailsResponse: Codable {
    let drinks: [Cocktail]
}

struct UsersResponse: Codable {
    let users: [User]
}

struct ReviewsResponse: Codable {
    let reviews: [Review]
}

struct BookmarksResponse: Codable {
    let bookmarks: [Bookmark]
}

// MARK: - Cocktail (Our local JSON server model)
struct Cocktail: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let description: String?
    let category: String
    let type: String
    let glass: String?
    let instructions: String?
    let ingredients: [String]
    let imageSource: String?
    let imageAlt: String?
    let tags: [String]?
    let difficulty: String?
    let prepTime: String?
    let servings: Int?
    let alcoholContent: String?
    let createdAt: TimeInterval
    let updatedAt: TimeInterval
    
    // Hashable based on id only
    static func == (lhs: Cocktail, rhs: Cocktail) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - User
struct User: Codable, Identifiable, Hashable {
    let id: String
    let email: String
    let password: String
    let createdAt: TimeInterval
    let updatedAt: TimeInterval
    let name: String?
    let dateOfBirth: String?
    let phone: String?
    let gender: String?
    let bookmarks: [String]? // Quick access; use /bookmarks endpoint for full details
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Review
struct Review: Codable, Identifiable, Hashable {
    let id: String
    let drinkId: String
    let authorId: String
    let rating: Int
    let comment: String
    let createdAt: TimeInterval
    
    static func == (lhs: Review, rhs: Review) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Bookmark
struct Bookmark: Codable, Identifiable, Hashable {
    let id: String
    let userId: String
    let drinkId: String
    let createdAt: TimeInterval
    
    static func == (lhs: Bookmark, rhs: Bookmark) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Helper Extensions
extension Cocktail {
    // Convenience computed properties with safe defaults
    var imageURL: URL? {
        guard let imageSource = imageSource else { return nil }
        return URL(string: imageSource)
    }
    
    var difficultyLevel: DifficultyLevel {
        guard let difficulty = difficulty else { return .medium }
        return DifficultyLevel(rawValue: difficulty) ?? .medium
    }
    
    var alcoholLevel: AlcoholLevel {
        guard let alcoholContent = alcoholContent else { return .medium }
        return AlcoholLevel(rawValue: alcoholContent) ?? .medium
    }
    
    var tagsArray: [String] {
        tags ?? []
    }
}

// MARK: - Enums
enum DifficultyLevel: String, Codable {
    case easy
    case medium
    case hard
}

enum AlcoholLevel: String, Codable {
    case none = "none"
    case low = "low"
    case medium = "medium"
    case high = "high"
    case veryHigh = "very high"
}

// MARK: - Display Models
// Combines review with author info for UI display
struct ReviewWithAuthor {
    let review: Review
    let authorEmail: String
    let authorName: String?
}
