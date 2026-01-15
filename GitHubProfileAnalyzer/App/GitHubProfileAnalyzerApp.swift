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
    
    @StateObject private var router = AppRouter()
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(router)
        }
    }
}

// MARK: - Root View

/// Root view that handles navigation based on app state
struct RootView: View {
    @EnvironmentObject private var router: AppRouter
    
    var body: some View {
        NavigationStack(path: $router.navigationPath) {
            SearchScreen()
                .navigationDestination(for: Route.self) { route in
                    router.view(for: route)
                }
        }
    }
}
