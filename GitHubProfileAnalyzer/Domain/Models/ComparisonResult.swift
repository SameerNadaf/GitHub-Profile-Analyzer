//
//  ComparisonResult.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import Foundation

// MARK: - Comparison Result

/// Result of comparing two GitHub profiles
struct ComparisonResult: Equatable, Sendable {
    
    // MARK: - Properties
    
    let profile1: ProfileData
    let profile2: ProfileData
    
    // MARK: - Computed Properties
    
    /// User who has more followers
    var followersWinner: String? {
        determineWinner(value1: profile1.user.followerCount, value2: profile2.user.followerCount)
    }
    
    /// User who has more public repos
    var reposWinner: String? {
        determineWinner(value1: profile1.user.publicRepoCount, value2: profile2.user.publicRepoCount)
    }
    
    /// User who has more stars
    var starsWinner: String? {
        determineWinner(value1: profile1.totalStars, value2: profile2.totalStars)
    }
    
    /// User with better health score
    var healthWinner: String? {
        guard let score1 = profile1.analysisResult?.healthScore.overall,
              let score2 = profile2.analysisResult?.healthScore.overall else { return nil }
        return determineWinner(value1: score1, value2: score2)
    }
    
    /// User with more recent activity
    var activityWinner: String? {
        determineWinner(value1: profile1.activityStatus.score, value2: profile2.activityStatus.score)
    }
    
    // MARK: - Private Methods
    
    private func determineWinner<T: Comparable>(value1: T, value2: T) -> String? {
        if value1 > value2 {
            return profile1.user.username
        } else if value2 > value1 {
            return profile2.user.username
        }
        return nil // Tie
    }
}
