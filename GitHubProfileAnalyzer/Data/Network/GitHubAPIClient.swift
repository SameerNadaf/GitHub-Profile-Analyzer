//
//  GitHubAPIClient.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import Foundation

// MARK: - GitHub API Client Protocol

/// Protocol for GitHub API operations
/// Enables dependency injection and testing
protocol GitHubAPIClientProtocol: Sendable {
    /// Fetch authenticated user profile
    func fetchAuthenticatedUser() async throws -> UserDTO
    
    /// Fetch user profile
    func fetchUser(username: String) async throws -> UserDTO
    
    /// Fetch user's repositories (paginated)
    func fetchRepositories(username: String, page: Int, perPage: Int) async throws -> [RepositoryDTO]
    
    /// Fetch all repositories for a user (handling pagination)
    func fetchAllRepositories(username: String, maxRepos: Int) async throws -> [RepositoryDTO]
    
    /// Fetch repository languages
    func fetchLanguages(owner: String, repo: String) async throws -> [String: Int]
    
    /// Fetch commit activity for a repository
    func fetchCommitActivity(owner: String, repo: String) async throws -> [WeeklyCommitActivityDTO]
    
    /// Fetch user events
    func fetchUserEvents(username: String, page: Int, perPage: Int) async throws -> [EventDTO]
}

// MARK: - GitHub API Client

/// Implementation of GitHub API client
final class GitHubAPIClient: GitHubAPIClientProtocol, @unchecked Sendable {
    
    // MARK: - Properties
    
    private let networkClient: NetworkClientProtocol
    
    // MARK: - Initialization
    
    init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    // MARK: - User Operations
    
    func fetchAuthenticatedUser() async throws -> UserDTO {
        let endpoint = GitHubEndpoint.authenticatedUser
        return try await networkClient.request(endpoint, responseType: UserDTO.self)
    }
    
    func fetchUser(username: String) async throws -> UserDTO {
        let endpoint = GitHubEndpoint.user(username: username)
        return try await networkClient.request(endpoint, responseType: UserDTO.self)
    }
    
    // MARK: - Repository Operations
    
    func fetchRepositories(username: String, page: Int = 1, perPage: Int = GitHubEndpoint.defaultPerPage) async throws -> [RepositoryDTO] {
        let endpoint = GitHubEndpoint.userRepos(username: username, page: page, perPage: perPage)
        return try await networkClient.request(endpoint, responseType: [RepositoryDTO].self)
    }
    
    func fetchAllRepositories(username: String, maxRepos: Int = 200) async throws -> [RepositoryDTO] {
        var allRepos: [RepositoryDTO] = []
        var currentPage = 1
        let perPage = GitHubEndpoint.maxPerPage
        
        while allRepos.count < maxRepos {
            let repos = try await fetchRepositories(username: username, page: currentPage, perPage: perPage)
            
            if repos.isEmpty {
                break // No more repos
            }
            
            allRepos.append(contentsOf: repos)
            currentPage += 1
            
            // If we got less than requested, we've reached the end
            if repos.count < perPage {
                break
            }
        }
        
        // Trim to maxRepos if we fetched more
        if allRepos.count > maxRepos {
            allRepos = Array(allRepos.prefix(maxRepos))
        }
        
        return allRepos
    }
    
    func fetchLanguages(owner: String, repo: String) async throws -> [String: Int] {
        let endpoint = GitHubEndpoint.repoLanguages(owner: owner, repo: repo)
        return try await networkClient.request(endpoint, responseType: [String: Int].self)
    }
    
    func fetchCommitActivity(owner: String, repo: String) async throws -> [WeeklyCommitActivityDTO] {
        let endpoint = GitHubEndpoint.repoCommitActivity(owner: owner, repo: repo)
        
        // This endpoint returns 202 if stats are being computed
        // In that case, we return empty array and caller should retry
        do {
            return try await networkClient.request(endpoint, responseType: [WeeklyCommitActivityDTO].self)
        } catch NetworkError.decodingError {
            // GitHub might return {} while computing - treat as empty
            return []
        }
    }
    
    // MARK: - Event Operations
    
    func fetchUserEvents(username: String, page: Int = 1, perPage: Int = GitHubEndpoint.defaultPerPage) async throws -> [EventDTO] {
        let endpoint = GitHubEndpoint.userEvents(username: username, page: page, perPage: perPage)
        return try await networkClient.request(endpoint, responseType: [EventDTO].self)
    }
}

// MARK: - DTOs (Data Transfer Objects)

/// User profile DTO from GitHub API
struct UserDTO: Codable, Equatable, Sendable {
    let id: Int
    let login: String
    let avatarUrl: String
    let htmlUrl: String
    let name: String?
    let company: String?
    let blog: String?
    let location: String?
    let email: String?
    let bio: String?
    let twitterUsername: String?
    let publicRepos: Int
    let publicGists: Int
    let followers: Int
    let following: Int
    let createdAt: Date
    let updatedAt: Date
}

/// Repository DTO from GitHub API
struct RepositoryDTO: Codable, Equatable, Sendable, Identifiable {
    let id: Int
    let name: String
    let fullName: String
    let owner: OwnerDTO
    let htmlUrl: String
    let description: String?
    let fork: Bool
    let createdAt: Date
    let updatedAt: Date
    let pushedAt: Date?
    let homepage: String?
    let size: Int
    let stargazersCount: Int
    let watchersCount: Int
    let language: String?
    let forksCount: Int
    let openIssuesCount: Int
    let defaultBranch: String
    let visibility: String?
    let topics: [String]?
    let archived: Bool?
    let disabled: Bool?
}

/// Repository owner DTO
struct OwnerDTO: Codable, Equatable, Sendable {
    let id: Int
    let login: String
    let avatarUrl: String
}

/// Weekly commit activity DTO
struct WeeklyCommitActivityDTO: Codable, Equatable, Sendable {
    /// Unix timestamp of the week start
    let week: Int
    /// Array of daily commit counts (7 days, starting Sunday)
    let days: [Int]
    /// Total commits for the week
    let total: Int
    
    /// Date representing the start of this week
    var weekDate: Date {
        Date(timeIntervalSince1970: TimeInterval(week))
    }
}

/// Event DTO from GitHub API
struct EventDTO: Codable, Equatable, Sendable, Identifiable {
    let id: String
    let type: String
    let actor: ActorDTO
    let repo: EventRepoDTO
    let createdAt: Date
    let `public`: Bool
}

/// Event actor DTO
struct ActorDTO: Codable, Equatable, Sendable {
    let id: Int
    let login: String
    let avatarUrl: String
}

/// Event repository DTO
struct EventRepoDTO: Codable, Equatable, Sendable {
    let id: Int
    let name: String
    let url: String
}
