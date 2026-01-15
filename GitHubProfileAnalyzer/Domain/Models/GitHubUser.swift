//
//  GitHubUser.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import Foundation

// MARK: - GitHub User

/// Domain model representing a GitHub user profile
/// Clean, immutable struct independent of API response structure
struct GitHubUser: Equatable, Identifiable, Sendable {
    
    // MARK: - Properties
    
    let id: Int
    let username: String
    let displayName: String?
    let avatarURL: URL?
    let profileURL: URL?
    let bio: String?
    let company: String?
    let location: String?
    let email: String?
    let blogURL: URL?
    let twitterUsername: String?
    
    // Stats
    let publicRepoCount: Int
    let publicGistCount: Int
    let followerCount: Int
    let followingCount: Int
    
    // Dates
    let accountCreatedAt: Date
    let lastUpdatedAt: Date
    
    // MARK: - Computed Properties
    
    /// Account age in years
    var accountAgeYears: Double {
        let interval = Date().timeIntervalSince(accountCreatedAt)
        return interval / (365.25 * 24 * 60 * 60)
    }
    
    /// Account age formatted as string
    var accountAgeFormatted: String {
        let years = Int(accountAgeYears)
        if years == 0 {
            let months = Int(accountAgeYears * 12)
            return months == 1 ? "1 month" : "\(months) months"
        }
        return years == 1 ? "1 year" : "\(years) years"
    }
    
    /// Follower to following ratio
    var followerRatio: Double {
        guard followingCount > 0 else {
            return followerCount > 0 ? Double(followerCount) : 0
        }
        return Double(followerCount) / Double(followingCount)
    }
    
    /// Follower ratio description
    var followerRatioDescription: String {
        if followerRatio >= 10 {
            return "Influencer (10x+ followers)"
        } else if followerRatio >= 2 {
            return "Popular (\(String(format: "%.1f", followerRatio))x followers)"
        } else if followerRatio >= 0.5 {
            return "Balanced"
        } else {
            return "Active follower"
        }
    }
    
    /// Whether the user has a complete profile
    var hasCompleteProfile: Bool {
        displayName != nil && bio != nil && location != nil
    }
    
    /// Profile completion percentage (0-100)
    var profileCompletionPercentage: Int {
        var score = 0
        let total = 6
        
        if displayName != nil { score += 1 }
        if bio != nil { score += 1 }
        if location != nil { score += 1 }
        if company != nil { score += 1 }
        if blogURL != nil { score += 1 }
        if twitterUsername != nil { score += 1 }
        
        return Int((Double(score) / Double(total)) * 100)
    }
}

// MARK: - User Activity Status

/// Represents the activity level of a user
enum UserActivityStatus: String, CaseIterable {
    case veryActive = "Very Active"
    case active = "Active"
    case moderate = "Moderate"
    case inactive = "Inactive"
    case dormant = "Dormant"
    
    /// Color representation for UI
    var colorName: String {
        switch self {
        case .veryActive: return "green"
        case .active: return "blue"
        case .moderate: return "yellow"
        case .inactive: return "orange"
        case .dormant: return "red"
        }
    }
    
    /// Icon name
    var iconName: String {
        switch self {
        case .veryActive: return "bolt.fill"
        case .active: return "flame.fill"
        case .moderate: return "clock.fill"
        case .inactive: return "moon.fill"
        case .dormant: return "zzz"
        }
    }
}
