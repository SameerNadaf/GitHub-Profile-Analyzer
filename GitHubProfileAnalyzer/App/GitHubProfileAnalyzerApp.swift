//
//  GitHubProfileAnalyzerApp.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import SwiftUI

@main
struct GitHubProfileAnalyzerApp: App {
    
    // MARK: - Properties
    
    /// Dependency container for service resolution
    @StateObject private var container = DependencyContainer.shared
    
    /// App router for navigation management
    @StateObject private var router = AppRouter()
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(router)
                .environmentObject(container)
        }
    }
}

// MARK: - Root View

/// Root view that handles navigation based on app state
/// Integrates NavigationStack with sheet and alert presentation
struct RootView: View {
    @EnvironmentObject private var router: AppRouter
    
    var body: some View {
        NavigationStack(path: $router.navigationPath) {
            SearchScreen()
                .navigationDestination(for: Route.self) { route in
                    router.view(for: route)
                }
        }
        .sheet(item: $router.presentedSheet) { route in
            NavigationStack {
                router.view(for: route)
            }
        }
        .alert(item: $router.presentedAlert) { alertItem in
            if let secondaryButton = alertItem.secondaryButton {
                Alert(
                    title: Text(alertItem.title),
                    message: Text(alertItem.message),
                    primaryButton: alertItem.primaryButton,
                    secondaryButton: secondaryButton
                )
            } else {
                Alert(
                    title: Text(alertItem.title),
                    message: Text(alertItem.message),
                    dismissButton: alertItem.primaryButton
                )
            }
        }
    }
}

// MARK: - Route Identifiable Extension

extension Route: Identifiable {
    var id: String {
        switch self {
        case .search:
            return "search"
        case .profile(let username):
            return "profile-\(username)"
        case .repositoryList(let username, _):
            return "repos-\(username)"
        case .comparison(let usernames):
            return "comparison-\(usernames.joined(separator: "-"))"
        }
    }
}
