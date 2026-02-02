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
    
    @StateObject private var viewModel: ComparisonViewModel
    
    // MARK: - Initialization
    
    init(usernames: [String]) {
        _viewModel = StateObject(wrappedValue: ComparisonViewModel(usernames: usernames))
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                switch viewModel.state {
                case .idle, .loading:
                    ComparisonSkeleton()
                    
                case .loaded(let result):
                    comparisonContent(result)
                    
                case .error(let message):
                    errorView(message)
                }
            }
            .padding()
        }
        .task {
            await viewModel.compareProfiles()
        }
        .alert("common_error", isPresented: Binding(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )) {
            Button("common_ok", role: .cancel) { }
        } message: {
            if let error = viewModel.error {
                Text(error)
            }
        }
    }
    
    // MARK: - Content
    
    private func comparisonContent(_ result: ComparisonResult) -> some View {
        VStack(spacing: 32) {
            // Avatars Header
            HStack(alignment: .top) {
                userHeader(user: result.profile1.user, isLeft: true)
                
                Text("comparison_vs")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.top, 40)
                
                userHeader(user: result.profile2.user, isLeft: false)
            }
            
            Divider()
            
            // Health Scores
            VStack(spacing: 8) {
                Text("comparison_health_score")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                ComparisonMetricRow(
                    title: "comparison_score",
                    value1: "\(Int(result.profile1.analysisResult?.healthScore.overall ?? 0))",
                    value2: "\(Int(result.profile2.analysisResult?.healthScore.overall ?? 0))",
                    winner: viewModel.winner(for: .score)
                )
            }
            
            // User Stats
            VStack(spacing: 8) {
                Text("comparison_community")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
                
                ComparisonMetricRow(
                    title: "profile_stats_followers",
                    value1: "\(result.profile1.user.followerCount)",
                    value2: "\(result.profile2.user.followerCount)",
                    winner: viewModel.winner(for: .followers)
                )
                
                ComparisonMetricRow(
                    title: "profile_stats_following",
                    value1: "\(result.profile1.user.followingCount)",
                    value2: "\(result.profile2.user.followingCount)",
                    winner: nil
                )
            }
            
            VStack(spacing: 8) {
                Text("comparison_repositories")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
                
                ComparisonMetricRow(
                    title: "comparison_metric_public_repos",
                    value1: "\(result.profile1.user.publicRepoCount)",
                    value2: "\(result.profile2.user.publicRepoCount)",
                    winner: viewModel.winner(for: .repos)
                )
                
                ComparisonMetricRow(
                    title: "comparison_metric_total_stars",
                    value1: "\(result.profile1.totalStars)",
                    value2: "\(result.profile2.totalStars)",
                    winner: viewModel.winner(for: .stars)
                )
                
                ComparisonMetricRow(
                    title: "comparison_metric_total_forks",
                    value1: "\(result.profile1.totalForks)",
                    value2: "\(result.profile2.totalForks)",
                    winner: viewModel.winner(for: .forks)
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
    
    private func errorView(_ message: String) -> some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
            .font(.largeTitle)
            .foregroundColor(.red)
            Text(message)
            .multilineTextAlignment(.center)
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
