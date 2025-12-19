//
//  ProfileView.swift
//  CocktailsApp
//
//  Created by Georgy GUEI on 12/19/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    @EnvironmentObject var authManager: AuthManager
    @State private var showLoginSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if !authManager.isAuthenticated {
                    // Not logged in state
                    VStack(spacing: 20) {
                        Image(systemName: "person.crop.circle.badge.xmark")
                            .font(.system(size: 70))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Not Logged In")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Login to access your profile and personalize your experience")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: { showLoginSheet = true }) {
                            Text("Login")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: 250)
                                .padding(.vertical, 14)
                                .background(Color.accentColor)
                                .cornerRadius(12)
                        }
                    }
                } else {
                    // Logged in state
                    ScrollView {
                        VStack(spacing: 32) {
                            // Profile Avatar
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 140, height: 140)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            .padding(.top, 32)
                            
                            // Profile Information
                            VStack(spacing: 0) {
                                if viewModel.isEditing {
                                    // Edit Mode
                                    ProfileEditRow(title: "Name", text: $viewModel.name, placeholder: "Your name")
                                    Divider()
                                    ProfileEditRow(title: "Date of birth", text: $viewModel.dateOfBirth, placeholder: "YYYY-MM-DD")
                                    Divider()
                                    ProfileEditRow(title: "Phone number", text: $viewModel.phone, placeholder: "+1234567890")
                                    Divider()
                                    ProfileEditRow(title: "Gender", text: $viewModel.gender, placeholder: "Gender")
                                    Divider()
                                    if let user = viewModel.currentUser {
                                        ProfileEditRow(title: "Email", text: .constant(user.email), placeholder: "Email")
                                    }
                                } else {
                                    // View Mode
                                    ProfileInfoRow(title: "Name", value: viewModel.name.isEmpty ? "-" : viewModel.name)
                                    Divider()
                                    ProfileInfoRow(title: "Date of birth", value: viewModel.dateOfBirth.isEmpty ? "-" : viewModel.dateOfBirth)
                                    Divider()
                                    ProfileInfoRow(title: "Phone number", value: viewModel.phone.isEmpty ? "-" : viewModel.phone)
                                    Divider()
                                    ProfileInfoRow(title: "Gender", value: viewModel.gender.isEmpty ? "-" : viewModel.gender)
                                    Divider()
                                    if let user = viewModel.currentUser {
                                        ProfileInfoRow(title: "Email", value: user.email)
                                    }
                                }
                                
                                // Password (only show in view mode)
                                if !viewModel.isEditing {
                                    Divider()
                                    HStack {
                                        Text("Password")
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Button("Change password") {
                                            // TODO: Implement password change
                                        }
                                        .font(.system(size: 15))
                                        .foregroundColor(.accentColor)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                }
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            
                            // Error Message
                            if let error = viewModel.errorMessage {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.horizontal)
                            }
                            
                            // Success Message
                            if viewModel.showSuccess {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Profile updated successfully")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }
                            
                            // Logout button
                            if !viewModel.isEditing {
                                Button(action: {
                                    viewModel.logout()
                                }) {
                                    HStack {
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                            .font(.system(size: 16))
                                        Text("Log Out")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        LinearGradient(
                                            colors: [Color(red: 1.0, green: 0.4, blue: 0.5), Color(red: 1.0, green: 0.3, blue: 0.4)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if authManager.isAuthenticated {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if viewModel.isEditing {
                            HStack(spacing: 12) {
                                Button("Cancel") {
                                    viewModel.cancelEditing()
                                }
                                .foregroundColor(.gray)
                                
                                Button("Save") {
                                    Task {
                                        await viewModel.saveProfile()
                                    }
                                }
                                .foregroundColor(.accentColor)
                                .disabled(viewModel.isLoading)
                            }
                        } else {
                            Button("Edit") {
                                viewModel.startEditing()
                            }
                            .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            .sheet(isPresented: $showLoginSheet) {
                LoginView()
            }
        }
        .task {
            if authManager.isAuthenticated {
                viewModel.loadUserData()
            }
        }
        .onChange(of: authManager.isAuthenticated) { oldValue, newValue in
            if newValue {
                viewModel.loadUserData()
            }
        }
    }
}

// MARK: - Profile Info Row (View Mode)
struct ProfileInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text(title)
                .foregroundColor(.secondary)
                .frame(minWidth: 120, alignment: .leading)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Profile Edit Row (Edit Mode)
struct ProfileEditRow: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text(title)
                .foregroundColor(.secondary)
                .frame(minWidth: 120, alignment: .leading)
            
            Spacer()
            
            TextField(placeholder, text: $text)
                .multilineTextAlignment(.trailing)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager.shared)
}
