//
//  LoginView.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import SwiftUI

/// Component providing login/logout functionality
struct LoginView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var oauthService: OAuthService
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var container: DependencyContainer
    
    @State private var currentUser: GitHubUser?
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            if isLoading {
                ProgressView()
                    .padding(.trailing, 8)
            }
            
            if oauthService.isAuthenticated {
                authenticatedView
            } else {
                loginButton
            }
        }
        .task(id: oauthService.isAuthenticated) {
            if oauthService.isAuthenticated {
                await fetchCurrentUser()
            } else {
                currentUser = nil
            }
        }
        .alert("Login Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Authenticated View
    
    private var authenticatedView: some View {
        Menu {
            if let user = currentUser {
                Button(action: {
                    router.navigate(to: .profile(username: user.username))
                }) {
                    Label("My Profile", systemImage: "person.circle")
                }
            }
            
            Button(role: .destructive, action: {
                oauthService.signOut()
            }) {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
            }
        } label: {
            HStack(spacing: 8) {
                if let user = currentUser {
                    // Avatar
                    AsyncImage(url: user.avatarURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    .shadow(radius: 2)
                } else {
                    // Loading placeholder
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 32, height: 32)
                }
            }
        }
    }
    
    // MARK: - Login Button
    
    private var loginButton: some View {
        Button(action: handleLogin) {
            Text("Sign In")
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.black)
                .cornerRadius(20)
        }
    }
    
    // MARK: - Actions
    
    private func handleLogin() {
        Task {
            isLoading = true
            do {
                _ = try await oauthService.signIn()
                // Fetch user will be triggered by .task
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isLoading = false
        }
    }
    
    private func fetchCurrentUser() async {
        guard currentUser == nil else { return }
        
        let useCase = FetchCurrentUserUseCase()
        
        do {
            currentUser = try await useCase.execute()
        } catch {
            print("Failed to fetch current user: \(error)")
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(OAuthService())
        .environmentObject(AppRouter())
}
