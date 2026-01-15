//
//  FetchProfileUseCase.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import Foundation

// MARK: - Fetch Profile Use Case Protocol

/// Protocol for fetching profile data
protocol FetchProfileUseCaseProtocol: Sendable {
    /// Fetch complete profile data for a username
    func execute(username: String) async throws -> ProfileData
}

// MARK: - Fetch Profile Use Case

/// Orchestrates fetching user profile, repositories, and activity data
/// Combines multiple API calls into a single ProfileData result
final class FetchProfileUseCase: FetchProfileUseCaseProtocol, @unchecked Sendable {
    
    // MARK: - Properties
    
    private let apiClient: GitHubAPIClientProtocol
    
    // MARK: - Initialization
    
    init(apiClient: GitHubAPIClientProtocol = GitHubAPIClient()) {
        self.apiClient = apiClient
    }
    
    // MARK: - Public Methods
    
    func execute(username: String) async throws -> ProfileData {
        // Validate username
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUsername.isEmpty else {
            throw ProfileError.userNotFound(username: username)
        }
        
        do {
            // Fetch user and repos concurrently
            async let userTask = apiClient.fetchUser(username: trimmedUsername)
            async let reposTask = apiClient.fetchAllRepositories(username: trimmedUsername, maxRepos: 100)
            async let eventsTask = fetchRecentEvents(username: trimmedUsername)
            
            let (userDTO, repoDTOs, events) = try await (userTask, reposTask, eventsTask)
            
            // Map DTOs to domain models
            let user = UserMapper.toDomain(userDTO)
            let repositories = RepositoryMapper.toDomain(repoDTOs)
            
            // Calculate language statistics from repos
            let languageStats = LanguageMapper.aggregateFromRepositories(repositories)
            
            // Determine activity status from events
            let activityStatus = determineActivityStatus(from: events)
            
            // Compute analysis with health score
            let analysisResult = ProfileHealthAnalyzer.analyze(
                user: user,
                repositories: repositories,
                activityStatus: activityStatus,
                languageStats: languageStats,
                events: events
            )
            
            return ProfileData(
                user: user,
                repositories: repositories,
                languageStats: languageStats,
                activityStatus: activityStatus,
                contributionSummary: nil,
                analysisResult: analysisResult,
                fetchedAt: Date()
            )
            
        } catch let error as NetworkError {
            throw ProfileError.from(error, username: trimmedUsername)
        } catch let error as ProfileError {
            throw error
        } catch {
            throw ProfileError.unknown(error.localizedDescription)
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchRecentEvents(username: String) async -> [UserEvent] {
        // Events API can fail for various reasons, treat as optional
        do {
            let eventDTOs = try await apiClient.fetchUserEvents(username: username, page: 1, perPage: 30)
            return EventMapper.toDomain(eventDTOs)
        } catch {
            // Events are optional, return empty on failure
            return []
        }
    }
    
    private func determineActivityStatus(from events: [UserEvent]) -> UserActivityStatus {
        guard !events.isEmpty else {
            return .dormant
        }
        
        // Get most recent event
        let sortedEvents = events.sorted { $0.createdAt > $1.createdAt }
        guard let mostRecent = sortedEvents.first else {
            return .dormant
        }
        
        let daysSinceActivity = mostRecent.ageInDays
        
        // Count coding activities in last 30 days
        let recentCodingEvents = events.filter { 
            $0.ageInDays <= 30 && $0.type.isCodingActivity 
        }.count
        
        switch (daysSinceActivity, recentCodingEvents) {
        case (0...7, 10...):
            return .veryActive
        case (0...7, 3...):
            return .active
        case (0...14, _):
            return .active
        case (15...30, _):
            return .moderate
        case (31...90, _):
            return .inactive
        default:
            return .dormant
        }
    }
}
