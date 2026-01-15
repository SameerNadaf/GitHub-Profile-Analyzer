//
//  OAuthService.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import Foundation
import AuthenticationServices

// MARK: - OAuth Service Protocol

protocol OAuthServiceProtocol {
    func signIn() async throws -> String
    func signOut()
    var isAuthenticated: Bool { get }
}

// MARK: - OAuth Service

/// Manages the OAuth 2.0 flow with GitHub
@MainActor
final class OAuthService: NSObject, OAuthServiceProtocol, ObservableObject {
    
    // MARK: - Properties
    
    private let tokenStore: TokenStoreProtocol
    private var webAuthSession: ASWebAuthenticationSession?
    
    @Published private(set) var isAuthenticated = false
    
    // MARK: - Init
    
    init(tokenStore: TokenStoreProtocol = TokenStore.shared) {
        self.tokenStore = tokenStore
        super.init()
        self.isAuthenticated = tokenStore.get() != nil
    }
    
    // MARK: - Public Methods
    
    /// Start the sign-in flow
    func signIn() async throws -> String {
        guard let authURL = OAuthConfiguration.authURL else {
            throw OAuthError.invalidConfiguration
        }
        
        // 1. Get authorization code via ASWebAuthenticationSession
        let callbackURL = try await authenticate(using: authURL)
        
        // 2. Extract code from callback
        guard let code = extractCode(from: callbackURL) else {
            throw OAuthError.missingCode
        }
        
        // 3. Exchange code for access token
        let token = try await exchangeCodeForToken(code)
        
        // 4. Save token
        try tokenStore.save(token: token)
        isAuthenticated = true
        
        return token
    }
    
    /// Sign out
    func signOut() {
        try? tokenStore.delete()
        isAuthenticated = false
        
        // Clear cookies (best effort)
        // ASWebAuthenticationSession handles its own cookies, usually ephemeral depending on config
    }
    
    // MARK: - Private Methods
    
    /// Authenticate using ASWebAuthenticationSession
    private func authenticate(using url: URL) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: "githubprofileanalyzer"
            ) { callbackURL, error in
                if let error = error {
                    // Check for cancellation
                    if (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        continuation.resume(throwing: OAuthError.cancelled)
                    } else {
                        continuation.resume(throwing: error)
                    }
                } else if let callbackURL = callbackURL {
                    continuation.resume(returning: callbackURL)
                } else {
                    continuation.resume(throwing: OAuthError.unknown)
                }
            }
            
            // Set context provider to self (if needed for window presentation)
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false // Keep cookies for convenience? Or true for clean login?
            session.start()
            self.webAuthSession = session
        }
    }
    
    /// Extract authorization code from callback URL
    private func extractCode(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return nil
        }
        return queryItems.first(where: { $0.name == "code" })?.value
    }
    
    /// Exchange code for access token via API
    private func exchangeCodeForToken(_ code: String) async throws -> String {
        
        var components = URLComponents(string: OAuthConfiguration.tokenURL)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: OAuthConfiguration.clientID),
            URLQueryItem(name: "client_secret", value: OAuthConfiguration.clientSecret),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: OAuthConfiguration.redirectURI)
        ]
        
        guard let url = components.url else {
            throw OAuthError.invalidConfiguration
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0, message: "Failed to exchange token")
        }
        
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        return tokenResponse.accessToken
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension OAuthService: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // Find the key window's scene
        @MainActor func window() -> UIWindow? {
             UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?
                .windows
                .first(where: { $0.isKeyWindow })
        }
        
        return window() ?? ASPresentationAnchor()
    }
}

// MARK: - Responses & Errors

struct TokenResponse: Codable {
    let accessToken: String
    let scope: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case scope
        case tokenType = "token_type"
    }
}

enum OAuthError: LocalizedError {
    case invalidConfiguration
    case missingCode
    case cancelled
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidConfiguration: return "Invalid OAuth configuration"
        case .missingCode: return "Authorization code missing from callback"
        case .cancelled: return "Login cancelled"
        case .unknown: return "Unknown authentication error"
        }
    }
}
