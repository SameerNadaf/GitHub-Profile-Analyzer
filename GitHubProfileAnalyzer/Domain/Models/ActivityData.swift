//
//  ActivityData.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import Foundation

// MARK: - Weekly Commit Activity

/// Represents commit activity for a single week
struct WeeklyCommitActivity: Equatable, Sendable {
    let weekStartDate: Date
    let dailyCommits: [Int] // 7 elements, Sunday to Saturday
    let totalCommits: Int
    
    /// Day with most commits this week
    var mostActiveDay: DayOfWeek? {
        guard let maxIndex = dailyCommits.indices.max(by: { dailyCommits[$0] < dailyCommits[$1] }),
              dailyCommits[maxIndex] > 0 else {
            return nil
        }
        return DayOfWeek(rawValue: maxIndex)
    }
    
    /// Average commits per day this week
    var averageCommitsPerDay: Double {
        Double(totalCommits) / 7.0
    }
}

// MARK: - Day of Week

enum DayOfWeek: Int, CaseIterable {
    case sunday = 0
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    
    var name: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
    
    var shortName: String {
        String(name.prefix(3))
    }
}

// MARK: - User Event

/// Domain model for a GitHub event
struct UserEvent: Equatable, Identifiable, Sendable {
    let id: String
    let type: EventType
    let repoName: String
    let createdAt: Date
    
    /// Age in days
    var ageInDays: Int {
        let interval = Date().timeIntervalSince(createdAt)
        return Int(interval / (24 * 60 * 60))
    }
}

// MARK: - Event Type

enum EventType: String, CaseIterable {
    case push = "PushEvent"
    case pullRequest = "PullRequestEvent"
    case pullRequestReview = "PullRequestReviewEvent"
    case issues = "IssuesEvent"
    case issueComment = "IssueCommentEvent"
    case create = "CreateEvent"
    case delete = "DeleteEvent"
    case fork = "ForkEvent"
    case watch = "WatchEvent"
    case release = "ReleaseEvent"
    case other = "Other"
    
    init(rawValue: String) {
        switch rawValue {
        case "PushEvent": self = .push
        case "PullRequestEvent": self = .pullRequest
        case "PullRequestReviewEvent": self = .pullRequestReview
        case "IssuesEvent": self = .issues
        case "IssueCommentEvent": self = .issueComment
        case "CreateEvent": self = .create
        case "DeleteEvent": self = .delete
        case "ForkEvent": self = .fork
        case "WatchEvent": self = .watch
        case "ReleaseEvent": self = .release
        default: self = .other
        }
    }
    
    var displayName: String {
        switch self {
        case .push: return "Push"
        case .pullRequest: return "Pull Request"
        case .pullRequestReview: return "PR Review"
        case .issues: return "Issue"
        case .issueComment: return "Comment"
        case .create: return "Create"
        case .delete: return "Delete"
        case .fork: return "Fork"
        case .watch: return "Star"
        case .release: return "Release"
        case .other: return "Activity"
        }
    }
    
    var iconName: String {
        switch self {
        case .push: return "arrow.up.circle"
        case .pullRequest: return "arrow.triangle.branch"
        case .pullRequestReview: return "eye"
        case .issues: return "exclamationmark.circle"
        case .issueComment: return "bubble.left"
        case .create: return "plus.circle"
        case .delete: return "minus.circle"
        case .fork: return "tuningfork"
        case .watch: return "star"
        case .release: return "tag"
        case .other: return "circle"
        }
    }
    
    /// Whether this event represents coding activity
    var isCodingActivity: Bool {
        switch self {
        case .push, .pullRequest, .pullRequestReview:
            return true
        default:
            return false
        }
    }
}

// MARK: - Contribution Summary

/// Summary of user's contribution activity
struct ContributionSummary: Equatable, Sendable {
    let totalCommits: Int
    let weeksWithActivity: Int
    let totalWeeks: Int
    let averageCommitsPerWeek: Double
    let mostActiveDay: DayOfWeek?
    let streakWeeks: Int // Consecutive weeks with commits
    let longestGapWeeks: Int // Longest gap without commits
    
    /// Activity consistency percentage
    var consistencyPercentage: Double {
        guard totalWeeks > 0 else { return 0 }
        return Double(weeksWithActivity) / Double(totalWeeks) * 100
    }
    
    /// Consistency rating
    var consistencyRating: String {
        switch consistencyPercentage {
        case 80...100: return "Excellent"
        case 60..<80: return "Good"
        case 40..<60: return "Moderate"
        case 20..<40: return "Sporadic"
        default: return "Low"
        }
    }
}

// MARK: - Language Statistics

/// Language usage statistics
struct LanguageStatistics: Equatable, Sendable {
    let languages: [LanguageUsage]
    
    /// Most used language
    var primary: LanguageUsage? {
        languages.first
    }
    
    /// Number of distinct languages
    var diversityCount: Int {
        languages.count
    }
    
    /// Diversity score (0-100)
    var diversityScore: Int {
        switch diversityCount {
        case 0: return 0
        case 1: return 20
        case 2: return 40
        case 3: return 60
        case 4...5: return 80
        default: return 100
        }
    }
}

/// Single language usage entry
struct LanguageUsage: Equatable, Identifiable, Sendable {
    let id = UUID()
    let name: String
    let bytes: Int
    let percentage: Double
    let repoCount: Int
    
    /// Color for the language (simplified)
    var colorHex: String {
        // Common language colors
        switch name.lowercased() {
        case "swift": return "#F05138"
        case "javascript": return "#F7DF1E"
        case "typescript": return "#3178C6"
        case "python": return "#3776AB"
        case "java": return "#B07219"
        case "kotlin": return "#A97BFF"
        case "go": return "#00ADD8"
        case "rust": return "#DEA584"
        case "ruby": return "#CC342D"
        case "c++", "cpp": return "#F34B7D"
        case "c#", "csharp": return "#239120"
        case "php": return "#777BB4"
        case "html": return "#E34F26"
        case "css": return "#563D7C"
        default: return "#6E7681"
        }
    }
}
