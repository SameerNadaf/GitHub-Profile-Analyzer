//
//  UserMapper.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import Foundation

// MARK: - User Mapper

/// Maps UserDTO to GitHubUser domain model
enum UserMapper {
    
    /// Convert UserDTO to domain model
    static func toDomain(_ dto: UserDTO) -> GitHubUser {
        GitHubUser(
            id: dto.id,
            username: dto.login,
            displayName: dto.name,
            avatarURL: URL(string: dto.avatarUrl),
            profileURL: URL(string: dto.htmlUrl),
            bio: dto.bio,
            company: dto.company?.trimmingCharacters(in: .whitespaces),
            location: dto.location?.trimmingCharacters(in: .whitespaces),
            email: dto.email,
            blogURL: Self.parseURL(dto.blog),
            twitterUsername: dto.twitterUsername,
            publicRepoCount: dto.publicRepos,
            publicGistCount: dto.publicGists,
            followerCount: dto.followers,
            followingCount: dto.following,
            accountCreatedAt: dto.createdAt,
            lastUpdatedAt: dto.updatedAt
        )
    }
    
    /// Parse URL string, handling common issues
    private static func parseURL(_ string: String?) -> URL? {
        guard var urlString = string?.trimmingCharacters(in: .whitespaces),
              !urlString.isEmpty else {
            return nil
        }
        
        // Add https:// if no scheme present
        if !urlString.contains("://") {
            urlString = "https://\(urlString)"
        }
        
        return URL(string: urlString)
    }
}

// MARK: - Event Mapper

/// Maps EventDTO to UserEvent domain model
enum EventMapper {
    
    static func toDomain(_ dto: EventDTO) -> UserEvent {
        UserEvent(
            id: dto.id,
            type: EventType(rawValue: dto.type),
            repoName: dto.repo.name,
            createdAt: dto.createdAt
        )
    }
    
    static func toDomain(_ dtos: [EventDTO]) -> [UserEvent] {
        dtos.map { toDomain($0) }
    }
}

// MARK: - Activity Mapper

/// Maps WeeklyCommitActivityDTO to WeeklyCommitActivity
enum ActivityMapper {
    
    static func toDomain(_ dto: WeeklyCommitActivityDTO) -> WeeklyCommitActivity {
        WeeklyCommitActivity(
            weekStartDate: dto.weekDate,
            dailyCommits: dto.days,
            totalCommits: dto.total
        )
    }
    
    static func toDomain(_ dtos: [WeeklyCommitActivityDTO]) -> [WeeklyCommitActivity] {
        dtos.map { toDomain($0) }
    }
    
    /// Create contribution summary from weekly data
    static func createSummary(from activities: [WeeklyCommitActivity]) -> ContributionSummary {
        let totalCommits = activities.reduce(0) { $0 + $1.totalCommits }
        let weeksWithActivity = activities.filter { $0.totalCommits > 0 }.count
        let totalWeeks = activities.count
        
        let averageCommits = totalWeeks > 0 
            ? Double(totalCommits) / Double(totalWeeks) 
            : 0
        
        // Find most active day across all weeks
        var dayCounts = [Int](repeating: 0, count: 7)
        for activity in activities {
            for (index, count) in activity.dailyCommits.enumerated() {
                dayCounts[index] += count
            }
        }
        
        let mostActiveDay = dayCounts.indices
            .max(by: { dayCounts[$0] < dayCounts[$1] })
            .flatMap { dayCounts[$0] > 0 ? DayOfWeek(rawValue: $0) : nil }
        
        // Calculate streak and longest gap
        let (streak, longestGap) = calculateStreakAndGap(activities)
        
        return ContributionSummary(
            totalCommits: totalCommits,
            weeksWithActivity: weeksWithActivity,
            totalWeeks: totalWeeks,
            averageCommitsPerWeek: averageCommits,
            mostActiveDay: mostActiveDay,
            streakWeeks: streak,
            longestGapWeeks: longestGap
        )
    }
    
    private static func calculateStreakAndGap(_ activities: [WeeklyCommitActivity]) -> (streak: Int, gap: Int) {
        var currentStreak = 0
        var maxStreak = 0
        var currentGap = 0
        var maxGap = 0
        
        // Process from oldest to newest
        let sorted = activities.sorted { $0.weekStartDate < $1.weekStartDate }
        
        for activity in sorted {
            if activity.totalCommits > 0 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
                maxGap = max(maxGap, currentGap)
                currentGap = 0
            } else {
                currentGap += 1
                currentStreak = 0
            }
        }
        
        return (maxStreak, max(maxGap, currentGap))
    }
}
