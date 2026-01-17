//
//  ComparisonScreen.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import SwiftUI

/// Screen that fetches and displays the comparison between two users
struct ComparisonScreen: View {
    
    // MARK: - Properties
    
    let usernames: [String]
    
    @State private var result: ComparisonResult?
    @State private var isLoading = true
    @State private var error: String?
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if isLoading {
                    ComparisonSkeleton()
                } else if let error = error {
                    errorView(error)
                } else if let result = result {
                    comparisonContent(result)
                }
            }
            .padding()
        }
        .task {
            await compareProfiles()
        }
    }
    
    // MARK: - Content
    
    private func comparisonContent(_ result: ComparisonResult) -> some View {
        VStack(spacing: 32) {
            // Avatars Header
            HStack(alignment: .top) {
                userHeader(user: result.profile1.user, isLeft: true)
                
                Text("VS")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.top, 40)
                
                userHeader(user: result.profile2.user, isLeft: false)
            }
            
            Divider()
            
            // Health Scores
            VStack(spacing: 8) {
                Text("Health Score")
                    .font(.headline)
                
                ComparisonMetricRow(
                    title: "Score",
                    value1: "\(Int(result.profile1.analysisResult?.healthScore.overall ?? 0))",
                    value2: "\(Int(result.profile2.analysisResult?.healthScore.overall ?? 0))",
                    winner: scoreWinner(result)
                )
            }
            
            // User Stats
            VStack(spacing: 8) {
                Text("Community")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                
                ComparisonMetricRow(
                    title: "Followers",
                    value1: "\(result.profile1.user.followerCount)",
                    value2: "\(result.profile2.user.followerCount)",
                    winner: winner(u1: result.profile1.user.username, u2: result.profile2.user.username, actual: result.followersWinner)
                )
                
                ComparisonMetricRow(
                    title: "Following",
                    value1: "\(result.profile1.user.followingCount)",
                    value2: "\(result.profile2.user.followingCount)",
                    winner: nil // Usually less is better? or neutral
                )
            }
            
            VStack(spacing: 8) {
                Text("Repositories")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                
                ComparisonMetricRow(
                    title: "Public Repos",
                    value1: "\(result.profile1.user.publicRepoCount)",
                    value2: "\(result.profile2.user.publicRepoCount)",
                    winner: winner(u1: result.profile1.user.username, u2: result.profile2.user.username, actual: result.reposWinner)
                )
                
                ComparisonMetricRow(
                    title: "Total Stars",
                    value1: "\(result.profile1.totalStars)",
                    value2: "\(result.profile2.totalStars)",
                    winner: winner(u1: result.profile1.user.username, u2: result.profile2.user.username, actual: result.starsWinner)
                )
                
                ComparisonMetricRow(
                    title: "Total Forks",
                    value1: "\(result.profile1.totalForks)",
                    value2: "\(result.profile2.totalForks)",
                    winner: result.profile1.totalForks > result.profile2.totalForks ? 1 : (result.profile2.totalForks > result.profile1.totalForks ? 2 : nil)
                )
            }
        }
    }
    
    private func userHeader(user: GitHubUser, isLeft: Bool) -> some View {
        VStack {
            AsyncImage(url: user.avatarURL) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .shadow(radius: 4)
            
            Text(user.username)
                .font(.headline)
                .lineLimit(1)
            
            if let name = user.displayName {
                Text(name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Helpers
    
    private func scoreWinner(_ result: ComparisonResult) -> Int? {
        guard let s1 = result.profile1.analysisResult?.healthScore.overall,
              let s2 = result.profile2.analysisResult?.healthScore.overall else { return nil }
        
        if s1 > s2 { return 1 }
        if s2 > s1 { return 2 }
        return nil
    }
    
    private func winner(u1: String, u2: String, actual: String?) -> Int? {
        guard let actual = actual else { return nil }
        if actual == u1 { return 1 }
        if actual == u2 { return 2 }
        return nil
    }
    
    private func errorView(_ message: String) -> some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text(message)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Logic
    
    private func compareProfiles() async {
        guard usernames.count == 2 else {
            error = "Invalid number of users"
            isLoading = false
            return
        }
        
        let useCase = CompareProfilesUseCase()
        
        do {
            result = try await useCase.execute(username1: usernames[0], username2: usernames[1])
            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }
}

// MARK: - Skeleton

struct ComparisonSkeleton: View {
    var body: some View {
        VStack(spacing: 32) {
            HStack {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 80, height: 80)
                    .overlay(ShimmerView(cornerRadius: 40))
                
                Spacer()
                
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 80, height: 80)
                    .overlay(ShimmerView(cornerRadius: 40))
            }
            .padding(.horizontal, 40)
            
            VStack(spacing: 16) {
                ForEach(0..<5) { _ in
                    ShimmerView()
                        .frame(height: 40)
                }
            }
        }
    }
}
