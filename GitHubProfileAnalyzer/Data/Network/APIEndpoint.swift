//
//  APIEndpoint.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import Foundation

// MARK: - API Endpoint Protocol

/// Protocol defining an API endpoint configuration
/// Enables type-safe endpoint definition and URL construction
protocol APIEndpoint {
    /// Base URL for the API
    var baseURL: String { get }
    
    /// Path component (e.g., "/users/octocat")
    var path: String { get }
    
    /// HTTP method
    var method: HTTPMethod { get }
    
    /// Query parameters
    var queryItems: [URLQueryItem]? { get }
    
    /// Request headers
    var headers: [String: String]? { get }
    
    /// Request body (for POST/PUT/PATCH)
    var body: Data? { get }
    
    /// Request timeout interval in seconds
    var timeoutInterval: TimeInterval { get }
}

// MARK: - Default Implementations

extension APIEndpoint {
    var queryItems: [URLQueryItem]? { nil }
    var headers: [String: String]? { nil }
    var body: Data? { nil }
    var timeoutInterval: TimeInterval { 30 }
    
    /// Construct the full URL from components
    var url: URL? {
        var components = URLComponents(string: baseURL)
        components?.path = path
        components?.queryItems = queryItems?.isEmpty == false ? queryItems : nil
        return components?.url
    }
    
    /// Build a URLRequest from this endpoint
    func asURLRequest() throws -> URLRequest {
        guard let url = url else {
            throw NetworkError.invalidURL("\(baseURL)\(path)")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeoutInterval
        
        // Set default headers
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Set custom headers
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Set body if present
        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return request
    }
}

// MARK: - GitHub API Constants

enum GitHubAPI {
    static let baseURL = "https://api.github.com"
    static let apiVersion = "2022-11-28"
    
    /// Standard headers for GitHub API
    static var standardHeaders: [String: String] {
        [
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": apiVersion
        ]
    }
}
