//
//  ProfileViewModel.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import Foundation
import SwiftUI

// MARK: - Profile View Model

/// ViewModel for the Profile screen
/// Manages state and coordinates data fetching
@MainActor
final class ProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var state: ProfileLoadingState = .idle
    @Published var showErrorAlert = false
    
    // MARK: - Properties
    
    let username: String
    private let fetchProfileUseCase: FetchProfileUseCaseProtocol
    private var fetchTask: Task<Void, Never>?
    
    // MARK: - Computed Properties
    
    var user: GitHubUser? {
        state.profileData?.user
    }
    
    var repositories: [Repository] {
        state.profileData?.repositories ?? []
    }
    
    var languageStats: LanguageStatistics? {
        state.profileData?.languageStats
    }
    
    var activityStatus: UserActivityStatus {
        state.profileData?.activityStatus ?? .dormant
    }
    
    var isLoading: Bool {
        state.isLoading
    }
    
    var hasError: Bool {
        state.error != nil
    }
    
    var errorMessage: String? {
        state.error?.errorDescription
    }
    
    // MARK: - Initialization
    
    init(username: String, fetchProfileUseCase: FetchProfileUseCaseProtocol = FetchProfileUseCase()) {
        self.username = username
        self.fetchProfileUseCase = fetchProfileUseCase
    }
    
    deinit {
        fetchTask?.cancel()
    }
    
    // MARK: - Public Methods
    
    /// Load profile data
    func loadProfile() {
        // Cancel any existing task
        fetchTask?.cancel()
        
        fetchTask = Task {
            await performFetch()
        }
    }
    
    /// Refresh profile data
    func refresh() {
        loadProfile()
    }
    
    /// Dismiss error state
    func dismissError() {
        showErrorAlert = false
    }
    
    // MARK: - Private Methods
    
    private func performFetch() async {
        // Don't reload if already loading
        guard !state.isLoading else { return }
        
        state = .loading
        
        do {
            let profileData = try await fetchProfileUseCase.execute(username: username)
            
            // Check if task was cancelled
            if Task.isCancelled { return }
            
            state = .loaded(profileData)
        } catch let error as ProfileError {
            if Task.isCancelled { return }
            state = .error(error)
            showErrorAlert = true
        } catch {
            if Task.isCancelled { return }
            state = .error(.unknown(error.localizedDescription))
            showErrorAlert = true
        }
    }
}

// MARK: - Preview Support

extension ProfileViewModel {
    /// Create a preview instance with mock data
    static func preview(username: String = "octocat") -> ProfileViewModel {
        let viewModel = ProfileViewModel(username: username)
        return viewModel
    }
}
