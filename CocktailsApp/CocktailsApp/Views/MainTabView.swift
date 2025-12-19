//
//  MainTabView.swift
//  CocktailsApp
//
//  Created by Georgy GUEI on 12/19/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedTab = 0
    @State private var showLoginSheet = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Cocktails Tab
            CocktailListView()
                .tabItem {
                    Label("Cocktails", systemImage: "wineglass.fill")
                }
                .tag(0)
            
            // Bookmarks Tab
            BookmarksView()
                .tabItem {
                    Label("Bookmarks", systemImage: "bookmark.fill")
                }
                .tag(1)
                .onAppear {
                    if !authManager.isAuthenticated {
                        showLoginSheet = true
                    }
                }
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
                .onAppear {
                    if !authManager.isAuthenticated {
                        showLoginSheet = true
                    }
                }
        }
        .accentColor(.accentColor)
        .sheet(isPresented: $showLoginSheet) {
            LoginView()
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            // Show login when switching to tabs that require authentication
            if !authManager.isAuthenticated && (newValue == 1 || newValue == 2) {
                showLoginSheet = true
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthManager.shared)
}
