//
//  Repository.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import Foundation

// MARK: - Repository

/// Domain model representing a GitHub repository
struct Repository: Equatable, Identifiable, Sendable {
    
    // MARK: - Properties
    
    let id: Int
    let name: String
    let fullName: String
    let ownerUsername: String
    let description: String?
    let htmlURL: URL?
    let homepage: URL?
    
    // Flags
    let isFork: Bool
    let isArchived: Bool
    let isDisabled: Bool
    
    // Stats
    let starCount: Int
    let forkCount: Int
    let watcherCount: Int
    let openIssueCount: Int
    let sizeKB: Int
    
    // Language & Topics
    let primaryLanguage: String?
    let topics: [String]
    
    // Dates
    let createdAt: Date
    let updatedAt: Date
    let pushedAt: Date?
    
    // MARK: - Computed Properties
    
    /// Whether this is an original (non-forked) repository
    var isOriginal: Bool {
        !isFork
    }
    
    /// Whether the repository is considered active (updated in last 6 months)
    var isActive: Bool {
        guard let pushedAt = pushedAt else { return false }
        let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
        return pushedAt > sixMonthsAgo
    }
    
    /// Repository age in days
    var ageInDays: Int {
        let interval = Date().timeIntervalSince(createdAt)
        return Int(interval / (24 * 60 * 60))
    }
    
    /// Days since last push
    var daysSinceLastPush: Int? {
        guard let pushedAt = pushedAt else { return nil }
        let interval = Date().timeIntervalSince(pushedAt)
        return Int(interval / (24 * 60 * 60))
    }
    
    /// Repository activity status
    var activityStatus: RepositoryActivityStatus {
        guard let daysSince = daysSinceLastPush else {
            return .unknown
        }
        
        switch daysSince {
        case 0...30:
            return .active
        case 31...90:
            return .recent
        case 91...180:
            return .moderate
        case 181...365:
            return .stale
        default:
            return .inactive
        }
    }
    
    /// Maintenance score (0-100) based on various factors
    var maintenanceScore: Int {
        var score = 0
        
        // Activity recency (40 points max)
        if let daysSince = daysSinceLastPush {
            if daysSince < 30 { score += 40 }
            else if daysSince < 90 { score += 30 }
            else if daysSince < 180 { score += 20 }
            else if daysSince < 365 { score += 10 }
        }
        
        // Has description (15 points)
        if description != nil && !description!.isEmpty { score += 15 }
        
        // Has topics (10 points)
        if !topics.isEmpty { score += 10 }
        
        // Community engagement - stars (20 points max)
        if starCount >= 100 { score += 20 }
        else if starCount >= 50 { score += 15 }
        else if starCount >= 10 { score += 10 }
        else if starCount >= 1 { score += 5 }
        
        // Not archived (10 points)
        if !isArchived { score += 10 }
        
        // Low open issues relative to stars (5 points)
        if starCount > 0 && openIssueCount <= starCount / 2 { score += 5 }
        
        return min(score, 100)
    }
    
    /// Star to age ratio (stars per year)
    var starsPerYear: Double {
        let years = max(Double(ageInDays) / 365.0, 0.1)
        return Double(starCount) / years
    }
}

// MARK: - Repository Activity Status

enum RepositoryActivityStatus: String, CaseIterable {
    case active = "Active"
    case recent = "Recent"
    case moderate = "Moderate"
    case stale = "Stale"
    case inactive = "Inactive"
    case unknown = "Unknown"
    
    var colorName: String {
        switch self {
        case .active: return "green"
        case .recent: return "blue"
        case .moderate: return "yellow"
        case .stale: return "orange"
        case .inactive, .unknown: return "gray"
        }
    }
    
    var localizedTitle: String {
        switch self {
        case .active: return String(localized: "status_active")
        case .recent: return String(localized: "status_recent")
        case .moderate: return String(localized: "status_moderate")
        case .stale: return String(localized: "status_stale")
        case .inactive: return String(localized: "status_inactive")
        case .unknown: return String(localized: "status_unknown")
        }
    }
}

// MARK: - Repository Collection Extensions

extension Array where Element == Repository {
    
    /// Filter to original (non-forked) repositories
    var originals: [Repository] {
        filter { $0.isOriginal }
    }
    
    /// Filter to active repositories
    var active: [Repository] {
        filter { $0.isActive }
    }
    
    /// Total star count
    var totalStars: Int {
        reduce(0) { $0 + $1.starCount }
    }
    
    /// Average maintenance score
    var averageMaintenanceScore: Double {
        guard !isEmpty else { return 0 }
        return Double(reduce(0) { $0 + $1.maintenanceScore }) / Double(count)
    }
    
    /// Most used language
    var mostUsedLanguage: String? {
        let languages = compactMap { $0.primaryLanguage }
        let counts = Dictionary(grouping: languages, by: { $0 }).mapValues { $0.count }
        return counts.max(by: { $0.value < $1.value })?.key
    }
    
    /// Language distribution
    var languageDistribution: [String: Int] {
        let languages = compactMap { $0.primaryLanguage }
        return Dictionary(grouping: languages, by: { $0 }).mapValues { $0.count }
    }
}
