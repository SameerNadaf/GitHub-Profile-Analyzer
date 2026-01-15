//
//  FetchCurrentUserUseCase.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import Foundation

// MARK: - Fetch Current User Use Case Protocol

protocol FetchCurrentUserUseCaseProtocol: Sendable {
    func execute() async throws -> GitHubUser
}

// MARK: - Fetch Current User Use Case

/// Fetches the currently authenticated user's profile
final class FetchCurrentUserUseCase: FetchCurrentUserUseCaseProtocol, @unchecked Sendable {
    
    // MARK: - Properties
    
    private let apiClient: GitHubAPIClientProtocol
    
    // MARK: - Initialization
    
    init(apiClient: GitHubAPIClientProtocol = GitHubAPIClient()) {
        self.apiClient = apiClient
    }
    
    // MARK: - Public Methods
    
    func execute() async throws -> GitHubUser {
        do {
            let userDTO = try await apiClient.fetchAuthenticatedUser()
            return UserMapper.toDomain(userDTO)
        } catch let error as NetworkError {
            throw ProfileError.networkError(error.localizedDescription)
        } catch {
            throw ProfileError.unknown(error.localizedDescription)
        }
    }
}
