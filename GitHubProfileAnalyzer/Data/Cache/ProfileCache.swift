//
//  ProfileCache.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import Foundation

// MARK: - Cached Profile Data

/// Codable version of ProfileData for caching
/// Excludes non-essential computed properties
struct CachedProfileData: Codable {
    let user: CachedUser
    let repositories: [CachedRepository]
    let languageStats: CachedLanguageStats
    let activityStatus: String // UserActivityStatus raw value
    let analysisResult: CachedAnalysisResult?
    let fetchedAt: Date
    
    init(from profileData: ProfileData) {
        self.user = CachedUser(from: profileData.user)
        self.repositories = profileData.repositories.map { CachedRepository(from: $0) }
        self.languageStats = CachedLanguageStats(from: profileData.languageStats)
        self.activityStatus = profileData.activityStatus.rawValue
        self.analysisResult = profileData.analysisResult.map { CachedAnalysisResult(from: $0) }
        self.fetchedAt = profileData.fetchedAt
    }
    
    func toProfileData() -> ProfileData {
        let user = self.user.toGitHubUser()
        let repos = self.repositories.map { $0.toRepository() }
        let stats = self.languageStats.toLanguageStatistics()
        let status = UserActivityStatus(rawValue: activityStatus) ?? .dormant
        let analysis = self.analysisResult?.toAnalysisResult()
        
        return ProfileData(
            user: user,
            repositories: repos,
            languageStats: stats,
            activityStatus: status,
            contributionSummary: nil,
            analysisResult: analysis,
            fetchedAt: fetchedAt
        )
    }
}

// MARK: - Cached User

struct CachedUser: Codable {
    let id: Int
    let username: String
    let displayName: String?
    let avatarURL: String?
    let profileURL: String?
    let bio: String?
    let company: String?
    let location: String?
    let email: String?
    let blogURL: String?
    let twitterUsername: String?
    let publicRepoCount: Int
    let publicGistCount: Int
    let followerCount: Int
    let followingCount: Int
    let accountCreatedAt: Date
    let lastUpdatedAt: Date
    
    init(from user: GitHubUser) {
        self.id = user.id
        self.username = user.username
        self.displayName = user.displayName
        self.avatarURL = user.avatarURL?.absoluteString
        self.profileURL = user.profileURL?.absoluteString
        self.bio = user.bio
        self.company = user.company
        self.location = user.location
        self.email = user.email
        self.blogURL = user.blogURL?.absoluteString
        self.twitterUsername = user.twitterUsername
        self.publicRepoCount = user.publicRepoCount
        self.publicGistCount = user.publicGistCount
        self.followerCount = user.followerCount
        self.followingCount = user.followingCount
        self.accountCreatedAt = user.accountCreatedAt
        self.lastUpdatedAt = user.lastUpdatedAt
    }
    
    func toGitHubUser() -> GitHubUser {
        GitHubUser(
            id: id,
            username: username,
            displayName: displayName,
            avatarURL: avatarURL.flatMap { URL(string: $0) },
            profileURL: profileURL.flatMap { URL(string: $0) },
            bio: bio,
            company: company,
            location: location,
            email: email,
            blogURL: blogURL.flatMap { URL(string: $0) },
            twitterUsername: twitterUsername,
            publicRepoCount: publicRepoCount,
            publicGistCount: publicGistCount,
            followerCount: followerCount,
            followingCount: followingCount,
            accountCreatedAt: accountCreatedAt,
            lastUpdatedAt: lastUpdatedAt
        )
    }
}

// MARK: - Cached Repository

struct CachedRepository: Codable {
    let id: Int
    let name: String
    let fullName: String
    let ownerUsername: String
    let description: String?
    let htmlURL: String?
    let homepage: String?
    let isFork: Bool
    let isArchived: Bool
    let isDisabled: Bool
    let starCount: Int
    let forkCount: Int
    let watcherCount: Int
    let openIssueCount: Int
    let sizeKB: Int
    let primaryLanguage: String?
    let topics: [String]
    let createdAt: Date
    let updatedAt: Date
    let pushedAt: Date?
    
    init(from repo: Repository) {
        self.id = repo.id
        self.name = repo.name
        self.fullName = repo.fullName
        self.ownerUsername = repo.ownerUsername
        self.description = repo.description
        self.htmlURL = repo.htmlURL?.absoluteString
        self.homepage = repo.homepage?.absoluteString
        self.isFork = repo.isFork
        self.isArchived = repo.isArchived
        self.isDisabled = repo.isDisabled
        self.starCount = repo.starCount
        self.forkCount = repo.forkCount
        self.watcherCount = repo.watcherCount
        self.openIssueCount = repo.openIssueCount
        self.sizeKB = repo.sizeKB
        self.primaryLanguage = repo.primaryLanguage
        self.topics = repo.topics
        self.createdAt = repo.createdAt
        self.updatedAt = repo.updatedAt
        self.pushedAt = repo.pushedAt
    }
    
    func toRepository() -> Repository {
        Repository(
            id: id,
            name: name,
            fullName: fullName,
            ownerUsername: ownerUsername,
            description: description,
            htmlURL: htmlURL.flatMap { URL(string: $0) },
            homepage: homepage.flatMap { URL(string: $0) },
            isFork: isFork,
            isArchived: isArchived,
            isDisabled: isDisabled,
            starCount: starCount,
            forkCount: forkCount,
            watcherCount: watcherCount,
            openIssueCount: openIssueCount,
            sizeKB: sizeKB,
            primaryLanguage: primaryLanguage,
            topics: topics,
            createdAt: createdAt,
            updatedAt: updatedAt,
            pushedAt: pushedAt
        )
    }
}

// MARK: - Cached Language Stats

struct CachedLanguageStats: Codable {
    let languages: [CachedLanguageUsage]
    
    init(from stats: LanguageStatistics) {
        self.languages = stats.languages.map { CachedLanguageUsage(from: $0) }
    }
    
    func toLanguageStatistics() -> LanguageStatistics {
        LanguageStatistics(languages: languages.map { $0.toLanguageUsage() })
    }
}

struct CachedLanguageUsage: Codable {
    let name: String
    let bytes: Int
    let percentage: Double
    let repoCount: Int
    
    init(from usage: LanguageUsage) {
        self.name = usage.name
        self.bytes = usage.bytes
        self.percentage = usage.percentage
        self.repoCount = usage.repoCount
    }
    
    func toLanguageUsage() -> LanguageUsage {
        LanguageUsage(name: name, bytes: bytes, percentage: percentage, repoCount: repoCount)
    }
}

// MARK: - Cached Analysis Result

struct CachedAnalysisResult: Codable {
    let healthScoreOverall: Int
    let healthScoreRating: String
    let analyzedAt: Date
    
    init(from result: AnalysisResult) {
        self.healthScoreOverall = result.healthScore.overall
        self.healthScoreRating = result.healthScore.rating
        self.analyzedAt = result.analyzedAt
    }
    
    func toAnalysisResult() -> AnalysisResult {
        // Create minimal analysis result for cached display
        let healthScore = HealthScore(
            overall: healthScoreOverall,
            breakdown: ScoreBreakdown(
                activity: CategoryScore(name: "Activity", score: 0, weight: 0.30, details: "Cached"),
                repositoryQuality: CategoryScore(name: "Repository Quality", score: 0, weight: 0.25, details: "Cached"),
                community: CategoryScore(name: "Community", score: 0, weight: 0.20, details: "Cached"),
                profileCompleteness: CategoryScore(name: "Profile", score: 0, weight: 0.15, details: "Cached"),
                languageDiversity: CategoryScore(name: "Languages", score: 0, weight: 0.10, details: "Cached")
            )
        )
        
        return AnalysisResult(
            healthScore: healthScore,
            activityAnalysis: ActivityAnalysis(
                status: .dormant,
                daysSinceLastActivity: nil,
                recentActivityCount: 0,
                activityTrend: .stable,
                mostActiveDay: nil,
                consistencyScore: 0
            ),
            repositoryAnalysis: RepositoryAnalysis(
                totalCount: 0,
                originalCount: 0,
                forkedCount: 0,
                activeCount: 0,
                archivedCount: 0,
                averageMaintenanceScore: 0,
                totalStars: 0,
                totalForks: 0,
                starToRepoRatio: 0,
                topRepositories: []
            ),
            communityAnalysis: CommunityAnalysis(
                followers: 0,
                following: 0,
                followerRatio: 0,
                engagementLevel: .newcomer
            ),
            profileAnalysis: ProfileCompletenessAnalysis(
                hasName: false,
                hasBio: false,
                hasLocation: false,
                hasCompany: false,
                hasBlog: false,
                hasTwitter: false,
                completionPercentage: 0
            ),
            languageAnalysis: LanguageDiversityAnalysis(
                totalLanguages: 0,
                primaryLanguage: nil,
                languageDistribution: [],
                diversityScore: 0
            ),
            analyzedAt: analyzedAt
        )
    }
}

// MARK: - Profile Cache

/// Profile-specific cache wrapper
actor ProfileCache {
    
    // MARK: - Properties
    
    private let cache: CacheManager
    private let ttl: TimeInterval
    
    // MARK: - Singleton
    
    static let shared = ProfileCache()
    
    // MARK: - Initialization
    
    init(cache: CacheManager = .shared, ttl: TimeInterval = 300) {
        self.cache = cache
        self.ttl = ttl
    }
    
    // MARK: - Public Methods
    
    /// Get cached profile for username
    func get(username: String) async -> ProfileData? {
        let key = cacheKey(for: username)
        guard let cached = await cache.get(key, type: CachedProfileData.self) else {
            return nil
        }
        return cached.toProfileData()
    }
    
    /// Cache profile data
    func set(_ profileData: ProfileData, for username: String) async {
        let key = cacheKey(for: username)
        let cached = CachedProfileData(from: profileData)
        await cache.set(key, value: cached, ttl: ttl)
    }
    
    /// Remove cached profile
    func remove(username: String) async {
        let key = cacheKey(for: username)
        await cache.remove(key)
    }
    
    /// Clear all cached profiles
    func clearAll() async {
        await cache.clear()
    }
    
    // MARK: - Private Methods
    
    private func cacheKey(for username: String) -> String {
        "profile_\(username.lowercased())"
    }
}
