//
//  AnalysisResult.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import Foundation

// MARK: - Analysis Result

/// Complete analysis result containing all computed metrics
struct AnalysisResult: Equatable, Sendable {
    
    // MARK: - Properties
    
    /// Overall profile health score (0-100)
    let healthScore: HealthScore
    
    /// Activity analysis results
    let activityAnalysis: ActivityAnalysis
    
    /// Repository analysis results
    let repositoryAnalysis: RepositoryAnalysis
    
    /// Community analysis results
    let communityAnalysis: CommunityAnalysis
    
    /// Profile completeness analysis
    let profileAnalysis: ProfileCompletenessAnalysis
    
    /// Language diversity analysis
    let languageAnalysis: LanguageDiversityAnalysis
    
    /// Timestamp when analysis was performed
    let analyzedAt: Date
}

// MARK: - Health Score

/// Composite health score with breakdown
struct HealthScore: Equatable, Sendable {
    /// Overall score (0-100)
    let overall: Int
    
    /// Score breakdown by category
    let breakdown: ScoreBreakdown
    
    /// Rating label
    var rating: String {
        switch overall {
        case 90...100: return "Excellent"
        case 75..<90: return "Very Good"
        case 60..<75: return "Good"
        case 45..<60: return "Fair"
        case 30..<45: return "Needs Work"
        default: return "Getting Started"
        }
    }
    
    /// Color for the score
    var colorName: String {
        switch overall {
        case 80...100: return "green"
        case 60..<80: return "blue"
        case 40..<60: return "yellow"
        case 20..<40: return "orange"
        default: return "red"
        }
    }
}

/// Score breakdown by category
struct ScoreBreakdown: Equatable, Sendable {
    let activity: CategoryScore
    let repositoryQuality: CategoryScore
    let community: CategoryScore
    let profileCompleteness: CategoryScore
    let languageDiversity: CategoryScore
    
    var all: [CategoryScore] {
        [activity, repositoryQuality, community, profileCompleteness, languageDiversity]
    }
}

/// Individual category score
struct CategoryScore: Equatable, Identifiable, Sendable {
    let id = UUID()
    let name: String
    let score: Int // 0-100
    let weight: Double // 0-1
    let details: String
    
    var weightedScore: Double {
        Double(score) * weight
    }
}

// MARK: - Activity Analysis

/// Analysis of user's activity patterns
struct ActivityAnalysis: Equatable, Sendable {
    let status: UserActivityStatus
    let daysSinceLastActivity: Int?
    let recentActivityCount: Int // Last 30 days
    let activityTrend: ActivityTrend
    let mostActiveDay: DayOfWeek?
    let consistencyScore: Int // 0-100
    
    var summary: String {
        switch status {
        case .veryActive:
            return "Highly active with consistent contributions"
        case .active:
            return "Regular activity with good engagement"
        case .moderate:
            return "Moderate activity level"
        case .inactive:
            return "Limited recent activity"
        case .dormant:
            return "No recent activity detected"
        }
    }
}

enum ActivityTrend: String, CaseIterable {
    case increasing = "Increasing"
    case stable = "Stable"
    case decreasing = "Decreasing"
    case inactive = "Inactive"
    
    var iconName: String {
        switch self {
        case .increasing: return "arrow.up.right"
        case .stable: return "arrow.right"
        case .decreasing: return "arrow.down.right"
        case .inactive: return "minus"
        }
    }
}

// MARK: - Repository Analysis

/// Analysis of repository quality and maintenance
struct RepositoryAnalysis: Equatable, Sendable {
    let totalCount: Int
    let originalCount: Int
    let forkedCount: Int
    let activeCount: Int
    let archivedCount: Int
    let averageMaintenanceScore: Double
    let totalStars: Int
    let totalForks: Int
    let starToRepoRatio: Double
    let topRepositories: [RepositorySummary]
    
    var originalPercentage: Double {
        guard totalCount > 0 else { return 0 }
        return Double(originalCount) / Double(totalCount) * 100
    }
    
    var activePercentage: Double {
        guard totalCount > 0 else { return 0 }
        return Double(activeCount) / Double(totalCount) * 100
    }
}

/// Summary of a repository for display
struct RepositorySummary: Equatable, Identifiable, Sendable {
    let id: Int
    let name: String
    let stars: Int
    let language: String?
    let maintenanceScore: Int
}

// MARK: - Community Analysis

/// Analysis of community engagement
struct CommunityAnalysis: Equatable, Sendable {
    let followers: Int
    let following: Int
    let followerRatio: Double
    let engagementLevel: EngagementLevel
    
    var summary: String {
        engagementLevel.description
    }
}

enum EngagementLevel: String, CaseIterable {
    case influencer = "Influencer"
    case established = "Established"
    case growing = "Growing"
    case emerging = "Emerging"
    case newcomer = "Newcomer"
    
    var description: String {
        switch self {
        case .influencer: return "Strong community influence with high follower count"
        case .established: return "Established presence with good engagement"
        case .growing: return "Building community presence"
        case .emerging: return "Starting to engage with the community"
        case .newcomer: return "New to the GitHub community"
        }
    }
    
    static func from(followers: Int, ratio: Double) -> EngagementLevel {
        switch (followers, ratio) {
        case (1000..., 5...): return .influencer
        case (500..., 2...) , (1000..., _): return .established
        case (100..., _), (_, 1...): return .growing
        case (10..., _): return .emerging
        default: return .newcomer
        }
    }
}

// MARK: - Profile Completeness Analysis

/// Analysis of profile information completeness
struct ProfileCompletenessAnalysis: Equatable, Sendable {
    let hasName: Bool
    let hasBio: Bool
    let hasLocation: Bool
    let hasCompany: Bool
    let hasBlog: Bool
    let hasTwitter: Bool
    let completionPercentage: Int
    
    var missingItems: [String] {
        var items: [String] = []
        if !hasName { items.append("Display name") }
        if !hasBio { items.append("Bio") }
        if !hasLocation { items.append("Location") }
        if !hasCompany { items.append("Company") }
        if !hasBlog { items.append("Website/Blog") }
        if !hasTwitter { items.append("Twitter/X") }
        return items
    }
}

// MARK: - Language Diversity Analysis

/// Analysis of programming language usage
struct LanguageDiversityAnalysis: Equatable, Sendable {
    let totalLanguages: Int
    let primaryLanguage: String?
    let languageDistribution: [LanguagePercentage]
    let diversityScore: Int // 0-100
    
    var diversityLevel: String {
        switch diversityScore {
        case 80...100: return "Polyglot"
        case 60..<80: return "Versatile"
        case 40..<60: return "Balanced"
        case 20..<40: return "Focused"
        default: return "Specialized"
        }
    }
}

struct LanguagePercentage: Equatable, Identifiable, Sendable {
    let id = UUID()
    let name: String
    let percentage: Double
}
