//
//  GitHubEndpoint.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import Foundation

// MARK: - GitHub Endpoint

/// Enum defining all GitHub API endpoints used in the app
enum GitHubEndpoint: APIEndpoint {
    
    // MARK: - User Endpoints
    
    /// Get user profile
    case user(username: String)
    
    /// Get user's repositories (paginated)
    case userRepos(username: String, page: Int, perPage: Int)
    
    /// Get user's events (for activity tracking)
    case userEvents(username: String, page: Int, perPage: Int)
    
    // MARK: - Repository Endpoints
    
    /// Get repository details
    case repository(owner: String, repo: String)
    
    /// Get repository languages
    case repoLanguages(owner: String, repo: String)
    
    /// Get repository commit activity (last year, weekly)
    case repoCommitActivity(owner: String, repo: String)
    
    /// Get repository contributors
    case repoContributors(owner: String, repo: String)
    
    // MARK: - APIEndpoint Protocol
    
    var baseURL: String {
        GitHubAPI.baseURL
    }
    
    var path: String {
        switch self {
        case .user(let username):
            return "/users/\(username)"
            
        case .userRepos(let username, _, _):
            return "/users/\(username)/repos"
            
        case .userEvents(let username, _, _):
            return "/users/\(username)/events"
            
        case .repository(let owner, let repo):
            return "/repos/\(owner)/\(repo)"
            
        case .repoLanguages(let owner, let repo):
            return "/repos/\(owner)/\(repo)/languages"
            
        case .repoCommitActivity(let owner, let repo):
            return "/repos/\(owner)/\(repo)/stats/commit_activity"
            
        case .repoContributors(let owner, let repo):
            return "/repos/\(owner)/\(repo)/contributors"
        }
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .userRepos(_, let page, let perPage):
            return [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "per_page", value: String(perPage)),
                URLQueryItem(name: "sort", value: "updated"),
                URLQueryItem(name: "direction", value: "desc")
            ]
            
        case .userEvents(_, let page, let perPage):
            return [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "per_page", value: String(perPage))
            ]
            
        default:
            return nil
        }
    }
    
    var headers: [String: String]? {
        var headers = GitHubAPI.standardHeaders
        
        // Add auth token if available (will be implemented in Phase 2)
        // if let token = TokenStore.shared.accessToken {
        //     headers["Authorization"] = "Bearer \(token)"
        // }
        
        return headers
    }
    
    var timeoutInterval: TimeInterval {
        switch self {
        case .repoCommitActivity:
            // This endpoint can be slow as GitHub computes stats on demand
            return 60
        default:
            return 30
        }
    }
}

// MARK: - Pagination Constants

extension GitHubEndpoint {
    /// Default page size for paginated requests
    static let defaultPerPage = 30
    
    /// Maximum allowed page size
    static let maxPerPage = 100
}
