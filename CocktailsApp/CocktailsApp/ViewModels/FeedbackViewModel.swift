//
//  FeedbackViewModel.swift
//  CocktailsApp
//
//  Created by imac13 on 18/12/2025.
//

import Foundation
import SwiftUI

@MainActor
class FeedbackViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var message: String = ""
    @Published var rating: Double = 3.0
    @Published var isSubmitting: Bool = false
    @Published var showSuccessAlert: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    
    private let feedbackService = FeedbackService()
    
    var isFormValid: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty &&
        !message.trimmingCharacters(in: .whitespaces).isEmpty &&
        rating > 0
    }
    
    func submitFeedback() async {
        guard isFormValid else { return }
        
        isSubmitting = true
        
        do {
            try await feedbackService.sendFeedback(
                username: username,
                message: message,
                rating: rating
            )
            
            // Reset form on success
            username = ""
            message = ""
            rating = 3.0
            showSuccessAlert = true
            isSubmitting = false
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
            isSubmitting = false
        }
    }
}
