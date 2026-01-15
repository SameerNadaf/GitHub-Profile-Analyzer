//
//  CompareProfilesUseCase.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import Foundation

// MARK: - Compare Profiles Use Case Protocol

protocol CompareProfilesUseCaseProtocol: Sendable {
    func execute(username1: String, username2: String) async throws -> ComparisonResult
}

// MARK: - Compare Profiles Use Case

/// Use case to fetch and compare two profiles
final class CompareProfilesUseCase: CompareProfilesUseCaseProtocol, @unchecked Sendable {
    
    // MARK: - Properties
    
    private let fetchProfileUseCase: FetchProfileUseCaseProtocol
    
    // MARK: - Initialization
    
    init(fetchProfileUseCase: FetchProfileUseCaseProtocol = FetchProfileUseCase()) {
        self.fetchProfileUseCase = fetchProfileUseCase
    }
    
    // MARK: - Comparison Logic
    
    func execute(username1: String, username2: String) async throws -> ComparisonResult {
        // Fetch both profiles concurrently
        async let profile1 = fetchProfileUseCase.execute(username: username1)
        async let profile2 = fetchProfileUseCase.execute(username: username2)
        
        // Wait for both results
        return try await ComparisonResult(
            profile1: profile1,
            profile2: profile2
        )
    }
}
