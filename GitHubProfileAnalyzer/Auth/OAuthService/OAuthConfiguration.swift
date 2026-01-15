//
//  OAuthConfiguration.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import Foundation

/// Configuration for GitHub OAuth
struct OAuthConfiguration {
    
    // MARK: - Credentials
    
    // TODO: Replace with your actual Client ID and Secret
    static let clientID = "YOUR_CLIENT_ID"
    static let clientSecret = "YOUR_CLIENT_SECRET"
    
    // MARK: - Configuration
    
    static let redirectURI = "githubprofileanalyzer://auth"
    static let authorizationURL = "https://github.com/login/oauth/authorize"
    static let tokenURL = "https://github.com/login/oauth/access_token"
    static let scopes = ["read:user", "user:email", "repo"] // repos for private access?
    
    // MARK: - URL Construction
    
    /// Constructs the URL for the authorization page
    static var authURL: URL? {
        var components = URLComponents(string: authorizationURL)
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "scope", value: scopes.joined(separator: " ")),
            URLQueryItem(name: "state", value: UUID().uuidString)
        ]
        return components?.url
    }
}
