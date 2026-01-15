//
//  AppRouter.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import SwiftUI

// MARK: - Route

/// Defines all navigable routes in the application
enum Route: Hashable {
    case search
    case profile(username: String)
    case comparison(usernames: [String])
}

// MARK: - App Router

/// Centralized navigation state management
/// Follows the Coordinator pattern adapted for SwiftUI
@MainActor
final class AppRouter: ObservableObject {
    
    // MARK: - Properties
    
    @Published var navigationPath = NavigationPath()
    
    // MARK: - Navigation Methods
    
    /// Navigate to a specific route
    func navigate(to route: Route) {
        navigationPath.append(route)
    }
    
    /// Pop the current view from navigation stack
    func pop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }
    
    /// Pop to root view
    func popToRoot() {
        navigationPath = NavigationPath()
    }
    
    // MARK: - View Factory
    
    /// Factory method to create views for routes
    /// This centralizes view creation and dependency injection
    @ViewBuilder
    func view(for route: Route) -> some View {
        switch route {
        case .search:
            SearchScreen()
            
        case .profile(let username):
            // TODO: Implement ProfileScreen in Step 6
            Text("Profile: \(username)")
                .font(.title)
            
        case .comparison(let usernames):
            // TODO: Implement ComparisonScreen in Step 13
            Text("Comparing: \(usernames.joined(separator: " vs "))")
                .font(.title)
        }
    }
}
