//
//  ComparisonViewModel.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 02/02/26.
//

import Foundation

// MARK: - Comparison View Model

/// ViewModel for the Comparison screen
/// Manages state and coordinates profile comparison
@MainActor
final class ComparisonViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var state: ComparisonState = .idle
    @Published var error: String?
    
    // MARK: - Properties
    
    let usernames: [String]
    private let compareProfilesUseCase: CompareProfilesUseCaseProtocol
    
    // MARK: - Initialization
    
    init(
        usernames: [String],
        compareProfilesUseCase: CompareProfilesUseCaseProtocol = CompareProfilesUseCase()
    ) {
        self.usernames = usernames
        self.compareProfilesUseCase = compareProfilesUseCase
    }
    
    // MARK: - Public Methods
    
    func compareProfiles() async {
        guard usernames.count == 2 else {
            state = .error("error_invalid_users")
            error = "error_invalid_users"
            return
        }
        
        state = .loading
        
        do {
            let result = try await compareProfilesUseCase.execute(username1: usernames[0], username2: usernames[1])
            state = .loaded(result)
        } catch {
            state = .error(error.localizedDescription)
            self.error = error.localizedDescription
        }
    }
    
    // MARK: - Helpers
    
    func winner(for category: ComparisonCategory) -> Int? {
        guard case .loaded(let result) = state else { return nil }
        
        switch category {
        case .score:
            guard let s1 = result.profile1.analysisResult?.healthScore.overall,
                  let s2 = result.profile2.analysisResult?.healthScore.overall else { return nil }
            return s1 > s2 ? 1 : (s2 > s1 ? 2 : nil)
            
        case .followers:
            return winnerIndex(u1: result.profile1.user.username, u2: result.profile2.user.username, actual: result.followersWinner)
            
        case .repos:
            return winnerIndex(u1: result.profile1.user.username, u2: result.profile2.user.username, actual: result.reposWinner)
            
        case .stars:
            return winnerIndex(u1: result.profile1.user.username, u2: result.profile2.user.username, actual: result.starsWinner)
            
        case .forks:
            let f1 = result.profile1.totalForks
            let f2 = result.profile2.totalForks
            return f1 > f2 ? 1 : (f2 > f1 ? 2 : nil)
        }
    }
    
    private func winnerIndex(u1: String, u2: String, actual: String?) -> Int? {
        guard let actual = actual else { return nil }
        if actual == u1 { return 1 }
        if actual == u2 { return 2 }
        return nil
    }
}

// MARK: - Comparison State

enum ComparisonState {
    case idle
    case loading
    case loaded(ComparisonResult)
    case error(String)
}

enum ComparisonCategory {
    case score
    case followers
    case repos
    case stars
    case forks
}
