//
//  ProfileData.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import Foundation

// MARK: - Profile Data

/// Aggregated container for all profile-related data
/// Used as the single source of truth for profile display
struct ProfileData: Equatable, Sendable {
    
    // MARK: - Properties
    
    /// User profile information
    let user: GitHubUser
    
    /// User's repositories
    let repositories: [Repository]
    
    /// Language statistics aggregated from repositories
    let languageStats: LanguageStatistics
    
    /// Activity status based on recent events
    let activityStatus: UserActivityStatus
    
    /// Contribution summary (optional, requires commit data)
    let contributionSummary: ContributionSummary?
    
    /// Analysis results with health score
    let analysisResult: AnalysisResult?
    
    /// Timestamp when this data was fetched
    let fetchedAt: Date
    
    // MARK: - Computed Properties
    
    /// Original (non-forked) repositories
    var originalRepos: [Repository] {
        repositories.originals
    }
    
    /// Active repositories
    var activeRepos: [Repository] {
        repositories.active
    }
    
    /// Total stars across all repos
    var totalStars: Int {
        repositories.totalStars
    }
    
    /// Average maintenance score
    var averageMaintenanceScore: Double {
        repositories.averageMaintenanceScore
    }
    
    /// Total forks across all repos
    var totalForks: Int {
        repositories.reduce(0) { $0 + $1.forkCount }
    }
    
    /// Star to repo ratio
    var starToRepoRatio: Double {
        guard !repositories.isEmpty else { return 0 }
        return Double(totalStars) / Double(repositories.count)
    }
    
    /// Most used programming language
    var primaryLanguage: String? {
        languageStats.primary?.name ?? repositories.mostUsedLanguage
    }
    
    /// Percentage of repos that are active
    var activeRepoPercentage: Double {
        guard !repositories.isEmpty else { return 0 }
        return Double(activeRepos.count) / Double(repositories.count) * 100
    }
    
    /// Whether the profile data is considered fresh (< 5 minutes old)
    var isFresh: Bool {
        fetchedAt.timeIntervalSinceNow > -300 // 5 minutes
    }
}

// MARK: - Profile Loading State

/// Represents the loading state of profile data
enum ProfileLoadingState: Equatable {
    case idle
    case loading
    case loaded(ProfileData)
    case error(ProfileError)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var profileData: ProfileData? {
        if case .loaded(let data) = self { return data }
        return nil
    }
    
    var error: ProfileError? {
        if case .error(let error) = self { return error }
        return nil
    }
}

// MARK: - Profile Error

/// Domain errors for profile operations
enum ProfileError: LocalizedError, Equatable {
    case userNotFound(username: String)
    case networkError(String)
    case rateLimited(retryAfter: Date?)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .userNotFound(let username):
            return "User '\(username)' not found"
        case .networkError(let message):
            return "Network error: \(message)"
        case .rateLimited(let retryAfter):
            if let date = retryAfter {
                let formatter = RelativeDateTimeFormatter()
                return "Rate limited. Try again \(formatter.localizedString(for: date, relativeTo: Date()))"
            }
            return "Rate limited. Please try again later"
        case .unknown(let message):
            return message
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .userNotFound:
            return "Double-check the username and try again"
        case .networkError:
            return "Check your internet connection"
        case .rateLimited:
            return "Sign in with GitHub for higher rate limits"
        case .unknown:
            return "Please try again"
        }
    }
    
    /// Create from NetworkError
    static func from(_ networkError: NetworkError, username: String? = nil) -> ProfileError {
        switch networkError {
        case .notFound:
            return .userNotFound(username: username ?? "Unknown")
        case .rateLimitExceeded(let resetDate):
            return .rateLimited(retryAfter: resetDate)
        case .noConnection, .timeout:
            return .networkError(networkError.errorDescription ?? "Connection failed")
        default:
            return .unknown(networkError.errorDescription ?? "Unknown error")
        }
    }
}
