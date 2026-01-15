//
//  EmptyStateView.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import SwiftUI

/// Reusable empty state component
struct EmptyStateView: View {
    
    // MARK: - Properties
    
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 8)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preset Empty States

extension EmptyStateView {
    
    /// No repositories found
    static func noRepositories(action: (() -> Void)? = nil) -> EmptyStateView {
        EmptyStateView(
            icon: "folder.badge.questionmark",
            title: "No Repositories",
            message: "This user doesn't have any public repositories yet.",
            actionTitle: nil,
            action: action
        )
    }
    
    /// No search results
    static func noSearchResults(query: String, action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No Results",
            message: "No repositories match '\(query)'",
            actionTitle: "Clear Search",
            action: action
        )
    }
    
    /// Network error
    static func networkError(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "wifi.slash",
            title: "Connection Error",
            message: "Please check your internet connection and try again.",
            actionTitle: "Retry",
            action: action
        )
    }
    
    /// User not found
    static func userNotFound(username: String) -> EmptyStateView {
        EmptyStateView(
            icon: "person.fill.questionmark",
            title: "User Not Found",
            message: "No GitHub user with the username '\(username)' exists.",
            actionTitle: nil,
            action: nil
        )
    }
    
    /// Rate limited
    static func rateLimited(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "clock.badge.exclamationmark",
            title: "Rate Limited",
            message: "GitHub API rate limit exceeded. Please try again later.",
            actionTitle: "Retry",
            action: action
        )
    }
}

// MARK: - Preview

#Preview {
    VStack {
        EmptyStateView.networkError {
            print("Retry tapped")
        }
    }
}
