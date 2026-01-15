//
//  ProfileScreen.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import SwiftUI

/// Profile screen that displays GitHub user analysis
/// This is a placeholder that will be enhanced in Step 6
struct ProfileScreen: View {
    
    // MARK: - Properties
    
    let username: String
    @EnvironmentObject private var router: AppRouter
    @State private var isLoading = false
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                profileHeader
                
                if isLoading {
                    loadingView
                } else {
                    placeholderContent
                }
            }
            .padding()
        }
        .navigationTitle(username)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: shareProfile) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar placeholder
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
                .overlay(
                    Text(username.prefix(1).uppercased())
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                )
                .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
            
            Text("@\(username)")
                .font(.title2.bold())
            
            Text("Profile data will load here")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Analyzing profile...")
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
    }
    
    private var placeholderContent: some View {
        VStack(spacing: 20) {
            // Stats placeholder
            HStack(spacing: 0) {
                statItem(title: "Repos", value: "--")
                Divider().frame(height: 40)
                statItem(title: "Followers", value: "--")
                Divider().frame(height: 40)
                statItem(title: "Following", value: "--")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Coming soon sections
            ForEach(["Profile Insights", "Repository Metrics", "Activity Analysis"], id: \.self) { section in
                sectionPlaceholder(title: section)
            }
        }
    }
    
    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func sectionPlaceholder(title: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
                .frame(height: 100)
                .overlay(
                    Text("Coming in Step 6+")
                        .foregroundColor(.secondary)
                )
        }
    }
    
    // MARK: - Actions
    
    private func shareProfile() {
        // TODO: Implement sharing in a later step
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProfileScreen(username: "octocat")
            .environmentObject(AppRouter())
    }
}
