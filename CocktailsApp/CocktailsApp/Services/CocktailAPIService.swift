//
//  CocktailAPIService.swift
//  CocktailsApp
//
//  Created by Georgy GUEI on 12/19/25.
//

import Foundation

// MARK: - API Errors
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case serverError(Int)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server error: \(statusCode)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Cocktail API Service
class CocktailAPIService {
    // Shared instance for convenience
    static let shared = CocktailAPIService()
    
    // Update this to your json-server URL
    static let baseURL = "http://localhost:4000"
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Generic Request Methods
    
    /// Generic GET request
    private func get<T: Decodable>(endpoint: String) async throws -> T {
        guard let url = URL(string: "\(Self.baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return decoded
            } catch {
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    /// Generic POST request
    private func post<T: Encodable, R: Decodable>(endpoint: String, body: T) async throws -> R {
        guard let url = URL(string: "\(Self.baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            throw APIError.decodingError(error)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            do {
                let decoded = try JSONDecoder().decode(R.self, from: data)
                return decoded
            } catch {
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    /// Generic PATCH request
    private func patch<T: Encodable, R: Decodable>(endpoint: String, body: T) async throws -> R {
        guard let url = URL(string: "\(Self.baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            throw APIError.decodingError(error)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            do {
                let decoded = try JSONDecoder().decode(R.self, from: data)
                return decoded
            } catch {
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    /// Generic DELETE request
    private func delete(endpoint: String) async throws {
        guard let url = URL(string: "\(Self.baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        do {
            let (_, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError(httpResponse.statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Cocktail Endpoints
    
    /// Fetch all cocktails
    func fetchCocktails() async throws -> [Cocktail] {
        return try await get(endpoint: "/drinks")
    }
    
    /// Fetch single cocktail by ID
    func fetchCocktail(id: String) async throws -> Cocktail {
        return try await get(endpoint: "/drinks/\(id)")
    }
    
    /// Search cocktails by query parameters (e.g., ?category=Cocktail&tags_like=tropical)
    func searchCocktails(query: String) async throws -> [Cocktail] {
        return try await get(endpoint: "/drinks?\(query)")
    }
    
    // MARK: - User Endpoints
    
    /// Fetch all users
    func fetchUsers() async throws -> [User] {
        return try await get(endpoint: "/users")
    }
    
    /// Fetch single user by ID
    func fetchUser(id: String) async throws -> User {
        return try await get(endpoint: "/users/\(id)")
    }
    
    /// Login user (query by email and password)
    func loginUser(email: String, password: String) async throws -> [User] {
        guard let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedPassword = password.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw APIError.invalidURL
        }
        let query = "email=\(encodedEmail)&password=\(encodedPassword)"
        return try await get(endpoint: "/users?\(query)")
    }
    
    /// Check if email exists
    func fetchUser(byEmail email: String) async throws -> [User] {
        guard let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw APIError.invalidURL
        }
        return try await get(endpoint: "/users?email=\(encodedEmail)")
    }
    
    /// Create new user
    func createUser(user: User) async throws -> User {
        return try await post(endpoint: "/users", body: user)
    }
    
    /// Update user (partial update)
    func updateUser(id: String, user: User) async throws -> User {
        return try await patch(endpoint: "/users/\(id)", body: user)
    }
    
    // MARK: - Review Endpoints
    
    /// Fetch all reviews
    func fetchReviews() async throws -> [Review] {
        return try await get(endpoint: "/reviews")
    }
    
    /// Fetch reviews for specific drink
    func fetchReviews(forDrinkId drinkId: String) async throws -> [Review] {
        return try await get(endpoint: "/reviews?drinkId=\(drinkId)")
    }
    
    /// Fetch reviews by specific author
    func fetchReviews(byAuthorId authorId: String) async throws -> [Review] {
        return try await get(endpoint: "/reviews?authorId=\(authorId)")
    }
    
    /// Create new review
    func createReview(review: Review) async throws -> Review {
        return try await post(endpoint: "/reviews", body: review)
    }
    
    /// Delete review
    func deleteReview(id: String) async throws {
        try await delete(endpoint: "/reviews/\(id)")
    }
    
    // MARK: - Bookmark Endpoints
    
    /// Fetch all bookmarks
    func fetchBookmarks() async throws -> [Bookmark] {
        return try await get(endpoint: "/bookmarks")
    }
    
    /// Fetch bookmarks for specific user
    func fetchBookmarks(forUserId userId: String) async throws -> [Bookmark] {
        return try await get(endpoint: "/bookmarks?userId=\(userId)")
    }
    
    /// Check if drink is bookmarked by user
    func isBookmarked(drinkId: String, userId: String) async throws -> Bool {
        let bookmarks: [Bookmark] = try await get(endpoint: "/bookmarks?userId=\(userId)&drinkId=\(drinkId)")
        return !bookmarks.isEmpty
    }
    
    /// Create bookmark
    func createBookmark(bookmark: Bookmark) async throws -> Bookmark {
        return try await post(endpoint: "/bookmarks", body: bookmark)
    }
    
    /// Delete bookmark
    func deleteBookmark(id: String) async throws {
        try await delete(endpoint: "/bookmarks/\(id)")
    }
    
    // MARK: - Helper Methods
    
    /// Calculate average rating for a drink
    func calculateAverageRating(forDrinkId drinkId: String) async throws -> Double {
        let reviews = try await fetchReviews(forDrinkId: drinkId)
        guard !reviews.isEmpty else { return 0.0 }
        let sum = reviews.reduce(0) { $0 + $1.rating }
        return Double(sum) / Double(reviews.count)
    }
    
    /// Fetch reviews with author information
    func fetchReviewsWithAuthors(forDrinkId drinkId: String) async throws -> [ReviewWithAuthor] {
        let reviews = try await fetchReviews(forDrinkId: drinkId)
        
        var reviewsWithAuthors: [ReviewWithAuthor] = []
        
        for review in reviews {
            do {
                let author = try await fetchUser(id: review.authorId)
                let reviewWithAuthor = ReviewWithAuthor(
                    review: review,
                    authorEmail: author.email,
                    authorName: author.name
                )
                reviewsWithAuthors.append(reviewWithAuthor)
            } catch {
                // Skip reviews where author fetch fails
                continue
            }
        }
        
        return reviewsWithAuthors
    }
}
