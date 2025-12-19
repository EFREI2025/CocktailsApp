//
//  LoginView.swift
//  CocktailsApp
//
//  Created by Georgy GUEI on 12/19/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Background Image - shows full image with proper aspect ratio
                Image("LoginBackground")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width)
                    .clipped()
                    .ignoresSafeArea()
                .ignoresSafeArea()
                
                // White Card - positioned to overlap image bottom
                VStack(spacing: 0) {
                    // Dynamic spacer to position card
                    Spacer()
                        .frame(height: geometry.size.height * 0.4)
                    
                    // White Card
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Welcome back!")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                            
                            (Text("Log in with your data. ")
                                .foregroundColor(.gray) +
                             Text("New here?")
                                .foregroundColor(.accentColor)
                                .fontWeight(.semibold) +
                             Text(" We'll create an account for you!")
                                .foregroundColor(.gray))
                                .font(.system(size: 14))
                                .lineSpacing(4)
                        }
                        .padding(.bottom, 5)
                        
                        // Email Field
                        HStack(spacing: 12) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                            
                            TextField("Email address", text: $viewModel.email)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .font(.system(size: 16))
                        }
                        .padding(16)
                        .background(Color(white: 0.95))
                        .cornerRadius(12)
                        
                        // Password Field
                        HStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                            
                            SecureField("Password", text: $viewModel.password)
                                .textContentType(.password)
                                .font(.system(size: 16))
                        }
                        .padding(16)
                        .background(Color(white: 0.95))
                        .cornerRadius(12)
                        
                        // Error Message
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }
                        
                        // Login Button
                        Button(action: {
                            Task {
                                let success = await viewModel.authenticate()
                                if success {
                                    dismiss()
                                }
                            }
                        }) {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Log in")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(viewModel.canSubmit ? Color.accentColor : Color.gray.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(!viewModel.canSubmit || viewModel.isLoading)
                        
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 30)
                    .padding(.bottom, 30)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    .shadow(color: .black.opacity(0.15), radius: 15, y: -5)
                }
                
                // Close Button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 50)
                    }
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
    }
}

// Extension for custom corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager.shared)
}
