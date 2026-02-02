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
            title: String(localized: "empty_no_repos_title"),
            message: String(localized: "empty_no_repos_message"),
            actionTitle: nil,
            action: action
        )
    }
    
    /// No search results
    static func noSearchResults(query: String, action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "magnifyingglass",
            title: String(localized: "empty_no_results_title"),
            message: String(format: String(localized: "empty_no_results_message_format"), query),
            actionTitle: String(localized: "empty_clear_search"),
            action: action
        )
    }
    
    /// Network error
    static func networkError(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "wifi.slash",
            title: String(localized: "empty_connection_error_title"),
            message: String(localized: "empty_connection_error_message"),
            actionTitle: String(localized: "common_try_again"),
            action: action
        )
    }
    
    /// User not found
    static func userNotFound(username: String) -> EmptyStateView {
        EmptyStateView(
            icon: "person.fill.questionmark",
            title: String(localized: "empty_user_not_found_title"),
            message: String(format: String(localized: "empty_user_not_found_message_format"), username),
            actionTitle: nil,
            action: nil
        )
    }
    
    /// Rate limited
    static func rateLimited(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "clock.badge.exclamationmark",
            title: String(localized: "empty_rate_limited_title"),
            message: String(localized: "empty_rate_limited_message"),
            actionTitle: String(localized: "common_try_again"),
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
