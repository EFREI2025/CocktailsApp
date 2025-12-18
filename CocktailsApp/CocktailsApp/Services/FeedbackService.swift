//
//  FeedbackService.swift
//  CocktailsApp
//
//  Created by imac13 on 18/12/2025.
//

import Foundation

enum FeedbackError: Error {
    case encodingError
    case decodingError
    case storageError
}

struct FeedbackItem: Codable, Identifiable {
    let id: UUID
    let username: String
    let message: String
    let rating: Double
    let date: Date
    
    init(id: UUID = UUID(), username: String, message: String, rating: Double, date: Date = Date()) {
        self.id = id
        self.username = username
        self.message = message
        self.rating = rating
        self.date = date
    }
}

class FeedbackService {
    private let storageKey = "com.cocktailsapp.feedback"
    
    func sendFeedback(username: String, message: String, rating: Double) async throws {
        let newFeedback = FeedbackItem(username: username, message: message, rating: rating)
        
        // Get existing feedback
        var feedbackList = try getAllFeedback()
        
        // Add new feedback
        feedbackList.append(newFeedback)
        
        // Save to UserDefaults
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(feedbackList)
            UserDefaults.standard.set(data, forKey: storageKey)
            print("✅ Feedback saved successfully")
        } catch {
            throw FeedbackError.encodingError
        }
    }
    
    func getAllFeedback() throws -> [FeedbackItem] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let feedbackList = try decoder.decode([FeedbackItem].self, from: data)
            return feedbackList
        } catch {
            throw FeedbackError.decodingError
        }
    }
    
    func clearAllFeedback() {
        UserDefaults.standard.removeObject(forKey: storageKey)
        print("🗑️ All feedback cleared")
    }
}
