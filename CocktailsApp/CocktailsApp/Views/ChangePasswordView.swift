//
//  ChangePasswordView.swift
//  CocktailsApp
//
//  Created by Georgy GUEI on 12/19/25.
//

import SwiftUI

struct ChangePasswordView: View {
    @StateObject private var viewModel = ChangePasswordViewModel()
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "lock.shield")
                                .font(.system(size: 60))
                                .foregroundColor(.accentColor)
                            
                            Text("Change Password")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Enter your current password and choose a new one")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 32)
                        
                        // Password Fields
                        VStack(spacing: 0) {
                            // Current Password
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Current Password")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 16)
                                
                                SecureField("Enter current password", text: $viewModel.currentPassword)
                                    .textContentType(.password)
                                    .autocapitalization(.none)
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(10)
                                    .padding(.horizontal, 16)
                            }
                            .padding(.vertical, 12)
                            
                            // New Password
                            VStack(alignment: .leading, spacing: 8) {
                                Text("New Password")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 16)
                                
                                SecureField("Enter new password", text: $viewModel.newPassword)
                                    .textContentType(.newPassword)
                                    .autocapitalization(.none)
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(10)
                                    .padding(.horizontal, 16)
                                
                                if !viewModel.newPassword.isEmpty && viewModel.newPassword.count < 6 {
                                    Text("Password must be at least 6 characters")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 16)
                                }
                            }
                            .padding(.vertical, 12)
                            
                            // Confirm Password
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Confirm New Password")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 16)
                                
                                SecureField("Re-enter new password", text: $viewModel.confirmPassword)
                                    .textContentType(.newPassword)
                                    .autocapitalization(.none)
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(10)
                                    .padding(.horizontal, 16)
                                
                                if !viewModel.confirmPassword.isEmpty && !viewModel.passwordsMatch {
                                    Text("Passwords don't match")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 16)
                                }
                            }
                            .padding(.vertical, 12)
                        }
                        
                        // Error Message
                        if let error = viewModel.errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(error)
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        
                        // Success Message
                        if viewModel.showSuccess {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Password changed successfully")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        
                        // Change Password Button
                        Button(action: {
                            Task {
                                let success = await viewModel.changePassword()
                                if success {
                                    // Close after a delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        dismiss()
                                    }
                                }
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Change Password")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(viewModel.canSubmit ? Color.accentColor : Color.gray.opacity(0.3))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .disabled(!viewModel.canSubmit || viewModel.isLoading)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                }
            }
        }
        .onDisappear {
            viewModel.clearForm()
        }
    }
}

#Preview {
    ChangePasswordView()
        .environmentObject(AuthManager.shared)
}
