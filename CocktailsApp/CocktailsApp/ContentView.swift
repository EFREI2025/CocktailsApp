//
//  ContentView.swift
//  CocktailsApp
//
//  Created by Georgy GUEI on 12/19/25.
//

import SwiftUI

struct ContentView: View {
    @State private var testResult = "Tap button to test API"
    @State private var isLoading = false
    @State private var drinks: [Cocktail] = []
    @State private var users: [User] = []
    
    var body: some View {
        VStack(spacing: 20) {
            Text("API Connection Test")
                .font(.title)
                .bold()
            
            if isLoading {
                ProgressView()
                    .padding()
            }
            
            Text(testResult)
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(testResult.contains("✅") ? .green : testResult.contains("❌") ? .red : .primary)
            
            Button("Test Drinks Endpoint") {
                Task { @MainActor in
                    await testDrinksEndpoint()
                }
            }
            .buttonStyle(.borderedProminent)
            
            Button("Test Users Endpoint") {
                Task { @MainActor in
                    await testUsersEndpoint()
                }
            }
            .buttonStyle(.bordered)
            
            if !drinks.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Drinks Found:")
                        .font(.headline)
                    ForEach(drinks) { drink in
                        Text("• \(drink.title) (\(drink.category))")
                            .font(.caption)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            if !users.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Users Found:")
                        .font(.headline)
                    ForEach(users) { user in
                        Text("• \(user.email)")
                            .font(.caption)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
    }
    
    func testDrinksEndpoint() async {
        isLoading = true
        testResult = "Testing drinks endpoint..."
        
        do {
            let fetchedDrinks = try await CocktailAPIService.shared.fetchCocktails()
            drinks = fetchedDrinks
            testResult = "✅ Success! Found \(fetchedDrinks.count) drinks"
        } catch {
            drinks = []
            testResult = "❌ Error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func testUsersEndpoint() async {
        isLoading = true
        testResult = "Testing users endpoint..."
        
        do {
            let fetchedUsers = try await CocktailAPIService.shared.fetchUsers()
            users = fetchedUsers
            testResult = "✅ Success! Found \(fetchedUsers.count) users"
        } catch {
            users = []
            testResult = "❌ Error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

#Preview {
    ContentView()
}
