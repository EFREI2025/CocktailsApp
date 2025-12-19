//
//  ContentView.swift
//  CocktailsApp
//
//  Created by Georgy GUEI on 12/19/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showLoginSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // User Status
                VStack(spacing: 15) {
                    Image(systemName: authManager.isAuthenticated ? "person.circle.fill" : "person.circle")
                        .font(.system(size: 80))
                        .foregroundColor(authManager.isAuthenticated ? .green : .gray)
                    
                    if authManager.isAuthenticated, let user = authManager.currentUser {
                        Text("Logged in as:")
                            .font(.headline)
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let name = user.name {
                            Text(name)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                    } else {
                        Text("Not logged in")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                
                // Action Buttons
                VStack(spacing: 15) {
                    if authManager.isAuthenticated {
                        Button("Logout") {
                            authManager.logout()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    } else {
                        Button("Login / Sign Up") {
                            showLoginSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("CocktailsApp")
            .sheet(isPresented: $showLoginSheet) {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager.shared)
}

#Preview {
    ContentView()
}
