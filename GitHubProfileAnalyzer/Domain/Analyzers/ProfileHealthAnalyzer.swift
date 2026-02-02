//
//  ProfileHealthAnalyzer.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import Foundation

// MARK: - Health Score Configuration

struct HealthScoreConfiguration: Sendable {
    let activityWeight: Double
    let repositoryWeight: Double
    let communityWeight: Double
    let profileWeight: Double
    let diversityWeight: Double
    
    static let standard = HealthScoreConfiguration(
        activityWeight: 0.30,
        repositoryWeight: 0.25,
        communityWeight: 0.20,
        profileWeight: 0.15,
        diversityWeight: 0.10
    )
}

// MARK: - Profile Health Analyzer

/// Computes the composite Profile Health Score
/// Formula: Activity (30%) + Repo Quality (25%) + Community (20%) + Profile (15%) + Diversity (10%)
struct ProfileHealthAnalyzer: Sendable {
    
    let configuration: HealthScoreConfiguration
    
    init(configuration: HealthScoreConfiguration = .standard) {
        self.configuration = configuration
    }
    
    // MARK: - Use Case Integration (Static Convenience)
    
    static func analyze(
        user: GitHubUser,
        repositories: [Repository],
        activityStatus: UserActivityStatus,
        languageStats: LanguageStatistics,
        events: [UserEvent] = []
    ) -> AnalysisResult {
        let analyzer = ProfileHealthAnalyzer()
        return analyzer.analyze(
            user: user,
            repositories: repositories,
            activityStatus: activityStatus,
            languageStats: languageStats,
            events: events
        )
    }
    
    // MARK: - Instance Methods
    
    /// Analyze profile and compute health score
    func analyze(
        user: GitHubUser,
        repositories: [Repository],
        activityStatus: UserActivityStatus,
        languageStats: LanguageStatistics,
        events: [UserEvent] = []
    ) -> AnalysisResult {
        
        // Compute individual analyses
        let activityAnalysis = analyzeActivity(
            status: activityStatus,
            events: events,
            repositories: repositories
        )
        
        let repositoryAnalysis = analyzeRepositories(repositories)
        let communityAnalysis = analyzeCommunity(user)
        let profileAnalysis = analyzeProfileCompleteness(user)
        let languageAnalysis = analyzeLanguageDiversity(languageStats, repositories: repositories)
        
        // Compute category scores
        let activityScore = computeActivityScore(activityAnalysis)
        let repoScore = computeRepositoryScore(repositoryAnalysis)
        let communityScore = computeCommunityScore(communityAnalysis)
        let profileScore = profileAnalysis.completionPercentage
        let diversityScore = languageAnalysis.diversityScore
        
        // Build breakdown
        let breakdown = ScoreBreakdown(
            activity: CategoryScore(
                name: String(localized: "health_category_activity"),
                score: activityScore,
                weight: configuration.activityWeight,
                details: activityAnalysis.summary
            ),
            repositoryQuality: CategoryScore(
                name: String(localized: "health_category_repo_quality"),
                score: repoScore,
                weight: configuration.repositoryWeight,
                details: String(format: String(localized: "health_details_maintenance_format"), Int(repositoryAnalysis.averageMaintenanceScore))
            ),
            community: CategoryScore(
                name: String(localized: "health_category_community"),
                score: communityScore,
                weight: configuration.communityWeight,
                details: communityAnalysis.summary
            ),
            profileCompleteness: CategoryScore(
                name: String(localized: "health_category_profile"),
                score: profileScore,
                weight: configuration.profileWeight,
                details: String(format: String(localized: "health_details_complete_format"), profileScore)
            ),
            languageDiversity: CategoryScore(
                name: String(localized: "health_category_languages"),
                score: diversityScore,
                weight: configuration.diversityWeight,
                details: languageAnalysis.diversityLevel
            )
        )
        
        // Compute weighted overall score
        let overall = Int(
            Double(activityScore) * configuration.activityWeight +
            Double(repoScore) * configuration.repositoryWeight +
            Double(communityScore) * configuration.communityWeight +
            Double(profileScore) * configuration.profileWeight +
            Double(diversityScore) * configuration.diversityWeight
        )
        
        let healthScore = HealthScore(overall: overall, breakdown: breakdown)
        
        return AnalysisResult(
            healthScore: healthScore,
            activityAnalysis: activityAnalysis,
            repositoryAnalysis: repositoryAnalysis,
            communityAnalysis: communityAnalysis,
            profileAnalysis: profileAnalysis,
            languageAnalysis: languageAnalysis,
            analyzedAt: Date()
        )
    }
    
    // MARK: - Activity Analysis
    
    private func analyzeActivity(
        status: UserActivityStatus,
        events: [UserEvent],
        repositories: [Repository]
    ) -> ActivityAnalysis {
        
        // Days since last activity
        let sortedEvents = events.sorted { $0.createdAt > $1.createdAt }
        let daysSinceLastActivity = sortedEvents.first?.ageInDays
        
        // Recent activity count (last 30 days)
        let recentActivityCount = events.filter { $0.ageInDays <= 30 }.count
        
        // Determine trend based on activity distribution
        let trend = determineTrend(events: events)
        
        // Find most active day from repos
        let pushDays = repositories.compactMap { $0.pushedAt }
            .map { Calendar.current.component(.weekday, from: $0) - 1 }
        let dayFrequency = Dictionary(grouping: pushDays, by: { $0 }).mapValues { $0.count }
        let mostActiveDay = dayFrequency.max(by: { $0.value < $1.value })
            .flatMap { DayOfWeek(rawValue: $0.key) }
        
        // Consistency score based on activity spread
        let consistencyScore = computeConsistencyScore(events: events, repositories: repositories)
        
        return ActivityAnalysis(
            status: status,
            daysSinceLastActivity: daysSinceLastActivity,
            recentActivityCount: recentActivityCount,
            activityTrend: trend,
            mostActiveDay: mostActiveDay,
            consistencyScore: consistencyScore
        )
    }
    
    private func determineTrend(events: [UserEvent]) -> ActivityTrend {
        guard events.count >= 5 else {
            return events.isEmpty ? .inactive : .stable
        }
        
        // Compare first half vs second half of events
        let midpoint = events.count / 2
        let recentEvents = events.prefix(midpoint).filter { $0.ageInDays <= 30 }.count
        let olderEvents = events.suffix(midpoint).filter { $0.ageInDays <= 60 && $0.ageInDays > 30 }.count
        
        if recentEvents > olderEvents + 2 {
            return .increasing
        } else if olderEvents > recentEvents + 2 {
            return .decreasing
        }
        return .stable
    }
    
    private func computeConsistencyScore(events: [UserEvent], repositories: [Repository]) -> Int {
        // Base on activity spread
        let activeRepos = repositories.filter { $0.isActive }.count
        let totalRepos = max(repositories.count, 1)
        let repoConsistency = Double(activeRepos) / Double(totalRepos)
        
        let recentEvents = events.filter { $0.ageInDays <= 90 }.count
        let eventConsistency = min(Double(recentEvents) / 30.0, 1.0)
        
        return Int((repoConsistency * 0.5 + eventConsistency * 0.5) * 100)
    }
    
    // MARK: - Repository Analysis
    
    private func analyzeRepositories(_ repositories: [Repository]) -> RepositoryAnalysis {
        let originals = repositories.filter { !$0.isFork }
        let active = repositories.filter { $0.isActive }
        let archived = repositories.filter { $0.isArchived }
        
        let avgMaintenance = repositories.isEmpty ? 0 :
            Double(repositories.reduce(0) { $0 + $1.maintenanceScore }) / Double(repositories.count)
        
        let totalStars = repositories.reduce(0) { $0 + $1.starCount }
        let totalForks = repositories.reduce(0) { $0 + $1.forkCount }
        
        let starRatio = repositories.isEmpty ? 0 :
            Double(totalStars) / Double(repositories.count)
        
        // Top repositories by stars
        let topRepos = repositories
            .sorted { $0.starCount > $1.starCount }
            .prefix(5)
            .map { RepositorySummary(
                id: $0.id,
                name: $0.name,
                stars: $0.starCount,
                language: $0.primaryLanguage,
                maintenanceScore: $0.maintenanceScore
            )}
        
        return RepositoryAnalysis(
            totalCount: repositories.count,
            originalCount: originals.count,
            forkedCount: repositories.count - originals.count,
            activeCount: active.count,
            archivedCount: archived.count,
            averageMaintenanceScore: avgMaintenance,
            totalStars: totalStars,
            totalForks: totalForks,
            starToRepoRatio: starRatio,
            topRepositories: Array(topRepos)
        )
    }
    
    // MARK: - Community Analysis
    
    private func analyzeCommunity(_ user: GitHubUser) -> CommunityAnalysis {
        let ratio = user.followerRatio
        let level = EngagementLevel.from(followers: user.followerCount, ratio: ratio)
        
        return CommunityAnalysis(
            followers: user.followerCount,
            following: user.followingCount,
            followerRatio: ratio,
            engagementLevel: level
        )
    }
    
    // MARK: - Profile Analysis
    
    private func analyzeProfileCompleteness(_ user: GitHubUser) -> ProfileCompletenessAnalysis {
        ProfileCompletenessAnalysis(
            hasName: user.displayName != nil && !user.displayName!.isEmpty,
            hasBio: user.bio != nil && !user.bio!.isEmpty,
            hasLocation: user.location != nil && !user.location!.isEmpty,
            hasCompany: user.company != nil && !user.company!.isEmpty,
            hasBlog: user.blogURL != nil,
            hasTwitter: user.twitterUsername != nil && !user.twitterUsername!.isEmpty,
            completionPercentage: user.profileCompletionPercentage
        )
    }
    
    // MARK: - Language Analysis
    
    private func analyzeLanguageDiversity(
        _ stats: LanguageStatistics,
        repositories: [Repository]
    ) -> LanguageDiversityAnalysis {
        let languages = repositories.compactMap { $0.primaryLanguage }
        let uniqueLanguages = Set(languages)
        
        let distribution = stats.languages.prefix(5).map {
            LanguagePercentage(name: $0.name, percentage: $0.percentage)
        }
        
        return LanguageDiversityAnalysis(
            totalLanguages: uniqueLanguages.count,
            primaryLanguage: stats.primary?.name ?? repositories.mostUsedLanguage,
            languageDistribution: Array(distribution),
            diversityScore: stats.diversityScore
        )
    }
    
    // MARK: - Score Computation
    
    private func computeActivityScore(_ analysis: ActivityAnalysis) -> Int {
        var score = 0
        
        // Status contribution (40 points)
        switch analysis.status {
        case .veryActive: score += 40
        case .active: score += 32
        case .moderate: score += 20
        case .inactive: score += 10
        case .dormant: score += 0
        }
        
        // Recency contribution (30 points)
        if let days = analysis.daysSinceLastActivity {
            switch days {
            case 0...7: score += 30
            case 8...14: score += 25
            case 15...30: score += 20
            case 31...60: score += 10
            default: score += 0
            }
        }
        
        // Consistency contribution (30 points)
        score += Int(Double(analysis.consistencyScore) * 0.3)
        
        return min(score, 100)
    }
    
    private func computeRepositoryScore(_ analysis: RepositoryAnalysis) -> Int {
        var score = 0
        
        // Has repos (10 points)
        if analysis.totalCount > 0 { score += 10 }
        
        // Original repos (20 points)
        if analysis.originalPercentage >= 70 { score += 20 }
        else if analysis.originalPercentage >= 50 { score += 15 }
        else if analysis.originalPercentage >= 30 { score += 10 }
        
        // Active repos (20 points)
        if analysis.activePercentage >= 50 { score += 20 }
        else if analysis.activePercentage >= 30 { score += 15 }
        else if analysis.activePercentage >= 10 { score += 10 }
        
        // Maintenance score (30 points)
        score += Int(analysis.averageMaintenanceScore * 0.3)
        
        // Stars (20 points)
        switch analysis.totalStars {
        case 1000...: score += 20
        case 500..<1000: score += 17
        case 100..<500: score += 14
        case 50..<100: score += 10
        case 10..<50: score += 6
        case 1..<10: score += 3
        default: score += 0
        }
        
        return min(score, 100)
    }
    
    private func computeCommunityScore(_ analysis: CommunityAnalysis) -> Int {
        var score = 0
        
        // Followers (50 points)
        switch analysis.followers {
        case 1000...: score += 50
        case 500..<1000: score += 40
        case 100..<500: score += 30
        case 50..<100: score += 20
        case 10..<50: score += 10
        case 1..<10: score += 5
        default: score += 0
        }
        
        // Engagement level (30 points)
        switch analysis.engagementLevel {
        case .influencer: score += 30
        case .established: score += 25
        case .growing: score += 18
        case .emerging: score += 10
        case .newcomer: score += 5
        }
        
        // Following shows engagement (20 points)
        if analysis.following >= 50 { score += 20 }
        else if analysis.following >= 20 { score += 15 }
        else if analysis.following >= 5 { score += 10 }
        
        return min(score, 100)
    }
}
