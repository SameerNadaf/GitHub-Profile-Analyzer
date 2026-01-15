//
//  AppRouter.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import SwiftUI

// MARK: - Route

/// Defines all navigable routes in the application
/// Conforms to Hashable for NavigationPath compatibility
enum Route: Hashable {
    case search
    case profile(username: String)
    case repositoryList(username: String)
    case comparison(usernames: [String])
    
    // MARK: - Route Metadata
    
    /// Display title for navigation bar
    var title: String {
        switch self {
        case .search:
            return "Search"
        case .profile(let username):
            return username
        case .repositoryList:
            return "Repositories"
        case .comparison:
            return "Compare Profiles"
        }
    }
}

// MARK: - App Router

/// Centralized navigation state management
/// Implements the Coordinator pattern adapted for SwiftUI's declarative navigation
///
/// Key responsibilities:
/// - Manage navigation stack state
/// - Provide view factory for route resolution
/// - Support deep linking (future)
/// - Enable testable navigation via protocol abstraction
@MainActor
final class AppRouter: ObservableObject {
    
    // MARK: - Properties
    
    @Published var navigationPath = NavigationPath()
    @Published var presentedSheet: Route?
    @Published var presentedAlert: AlertItem?
    
    /// Reference to dependency container for view creation
    private let container: DependencyContainer
    
    // MARK: - Initialization
    
    init(container: DependencyContainer = .shared) {
        self.container = container
    }
    
    // MARK: - Navigation Methods
    
    /// Navigate to a specific route (push)
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
    
    /// Pop multiple levels
    func pop(count: Int) {
        let removeCount = min(count, navigationPath.count)
        navigationPath.removeLast(removeCount)
    }
    
    /// Present a route as a sheet
    func presentSheet(_ route: Route) {
        presentedSheet = route
    }
    
    /// Dismiss any presented sheet
    func dismissSheet() {
        presentedSheet = nil
    }
    
    /// Show an alert
    func showAlert(_ alert: AlertItem) {
        presentedAlert = alert
    }
    
    // MARK: - View Factory
    
    /// Factory method to create views for routes
    /// Centralizes view creation and dependency injection
    ///
    /// - Parameter route: The route to create a view for
    /// - Returns: The appropriate view for the route
    @ViewBuilder
    func view(for route: Route) -> some View {
        switch route {
        case .search:
            SearchScreen()
            
        case .profile(let username):
            ProfileScreen(username: username)
            
        case .repositoryList(let username):
            // RepositoryListScreen will fetch its own data
            RepositoryListScreen(repositories: [], username: username)
            
        case .comparison(let usernames):
            ComparisonPlaceholderView(usernames: usernames)
        }
    }
}

// MARK: - Alert Item

/// Model for presenting alerts through the router
struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let primaryButton: Alert.Button
    let secondaryButton: Alert.Button?
    
    init(
        title: String,
        message: String,
        primaryButton: Alert.Button = .default(Text("OK")),
        secondaryButton: Alert.Button? = nil
    ) {
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }
}

// MARK: - Comparison Placeholder

/// Placeholder view for comparison feature (Phase 3)
struct ComparisonPlaceholderView: View {
    let usernames: [String]
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Compare Profiles")
                .font(.title2.bold())
            
            Text("Comparing: \(usernames.joined(separator: " vs "))")
                .foregroundColor(.secondary)
            
            Text("Coming in Phase 3")
                .font(.caption)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(8)
        }
        .navigationTitle("Compare")
    }
}
