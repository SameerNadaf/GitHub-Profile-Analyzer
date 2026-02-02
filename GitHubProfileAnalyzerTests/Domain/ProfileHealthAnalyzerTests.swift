//
//  ProfileHealthAnalyzerTests.swift
//  GitHubProfileAnalyzerTests
//
//  Created by Sameer Nadaf on 02/02/26.
//

import XCTest
@testable import GitHubProfileAnalyzer

final class ProfileHealthAnalyzerTests: XCTestCase {
    
    // MARK: - Test Data
    
    private let mockUser = GitHubUser(
        id: 1,
        username: "testuser",
        displayName: "Test User",
        avatarURL: nil,
        profileURL: nil,
        bio: "Bio",
        company: "Company",
        location: "Location",
        email: "test@example.com",
        blogURL: nil,
        twitterUsername: "test",
        publicRepoCount: 10,
        publicGistCount: 0,
        followerCount: 100,
        followingCount: 50,
        accountCreatedAt: Date(),
        lastUpdatedAt: Date()
    )
    
    private let mockLanguageStats = LanguageStatistics(languages: [])

    // MARK: - Tests
    
    func testStandardConfigurationScore() {
        // Given
        let analyzer = ProfileHealthAnalyzer(configuration: .standard)
        
        // When
        let result = analyzer.analyze(
            user: mockUser,
            repositories: [],
            activityStatus: .active,
            languageStats: mockLanguageStats,
            events: []
        )
        
        // Then
        XCTAssertNotNil(result.healthScore)
        // Verify weights in breakdown match standard config
        XCTAssertEqual(result.healthScore.breakdown.activity.weight, 0.30)
        XCTAssertEqual(result.healthScore.breakdown.repositoryQuality.weight, 0.25)
    }
    
    func testCustomConfigurationScore() {
        // Given
        let customConfig = HealthScoreConfiguration(
            activityWeight: 0.50,
            repositoryWeight: 0.10,
            communityWeight: 0.10,
            profileWeight: 0.15,
            diversityWeight: 0.15
        )
        let analyzer = ProfileHealthAnalyzer(configuration: customConfig)
        
        // When
        let result = analyzer.analyze(
            user: mockUser,
            repositories: [],
            activityStatus: .active,
            languageStats: mockLanguageStats,
            events: []
        )
        
        // Then
        XCTAssertEqual(result.healthScore.breakdown.activity.weight, 0.50)
        XCTAssertEqual(result.healthScore.breakdown.repositoryQuality.weight, 0.10)
    }
    
    func testActivityScoreCalculation() {
        // Given
        let analyzer = ProfileHealthAnalyzer()
        
        // When (Active status = 32 points)
        let result = analyzer.analyze(
            user: mockUser,
            repositories: [],
            activityStatus: .active,
            languageStats: mockLanguageStats
        )
        
        // Then
        // Activity score should be > 0
        XCTAssertGreaterThan(result.healthScore.breakdown.activity.score, 0)
    }
}
