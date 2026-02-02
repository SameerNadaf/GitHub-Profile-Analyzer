//
//  ProfileScreen.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import SwiftUI

/// Profile screen that displays GitHub user analysis
struct ProfileScreen: View {
    
    // MARK: - Properties
    
    let username: String
    @StateObject private var viewModel: ProfileViewModel
    @EnvironmentObject private var router: AppRouter
    
    // MARK: - Initialization
    
    init(username: String) {
        self.username = username
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(username: username))
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                switch viewModel.state {
                case .idle, .loading:
                    loadingView
                    
                case .loaded(let profileData):
                    profileContent(profileData)
                    
                case .error(let error):
                    errorView(error)
                }
            }
            .padding()
        }
        .navigationTitle(username)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.state.profileData != nil {
                    Button(action: shareProfile) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .refreshable {
            viewModel.refresh()
        }
        .task {
            viewModel.loadProfile()
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        ProfileSkeleton()
    }
    
    // MARK: - Profile Content
    
    private func profileContent(_ data: ProfileData) -> some View {
        VStack(spacing: 24) {
            profileHeader(data.user)
            statsBar(data)
            
            // Health Score Card
            if let analysis = data.analysisResult {
                HealthScoreCard(healthScore: analysis.healthScore)
            }
            
            activityStatusCard(data.activityStatus)
            
            // Charts Section
            LanguageChart(languages: data.languageStats.languages)
            ActivityChart(repositories: data.repositories)
            StatsChart(repositories: data.repositories)
            
            repositorySummary(data)
        }
    }
    
    private func profileHeader(_ user: GitHubUser) -> some View {
        VStack(spacing: 16) {
            // Avatar
            AsyncImage(url: user.avatarURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(.gray)
                default:
                    Circle()
                        .fill(Color(.systemGray5))
                        .overlay(ProgressView())
                }
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            
            VStack(spacing: 4) {
                if let displayName = user.displayName {
                    Text(displayName)
                        .font(.title2.bold())
                }
                
                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let bio = user.bio {
                Text(bio)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            // Account info badges
            HStack(spacing: 16) {
                Label(user.accountAgeFormatted, systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let location = user.location {
                    Label(location, systemImage: "mappin")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.top, 8)
    }
    
    private func statsBar(_ data: ProfileData) -> some View {
        HStack(spacing: 0) {
            statItem(title: "profile_stats_repos", value: "\(data.user.publicRepoCount)")
            Divider().frame(height: 40)
            statItem(title: "profile_stats_followers", value: formatNumber(data.user.followerCount))
            Divider().frame(height: 40)
            statItem(title: "profile_stats_following", value: formatNumber(data.user.followingCount))
            Divider().frame(height: 40)
            statItem(title: "profile_stats_stars", value: formatNumber(data.totalStars))
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold())
            Text(LocalizedStringKey(title))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func activityStatusCard(_ status: UserActivityStatus) -> some View {
        HStack {
            Image(systemName: status.iconName)
                .font(.title2)
                .foregroundColor(colorForStatus(status))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("profile_activity_status")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(status.rawValue)
                    .font(.headline)
                    .foregroundColor(colorForStatus(status))
            }
            
            Spacer()
        }
        .padding()
        .background(colorForStatus(status).opacity(0.1))
        .cornerRadius(12)
    }
    
    private func repositorySummary(_ data: ProfileData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("profile_repo_summary")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    router.navigate(to: .repositoryList(username: username, totalCount: data.repositories.count))
                }) {
                    HStack(spacing: 4) {
                        Text("common_see_all")
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
            
            VStack(spacing: 8) {
                summaryRow(label: "profile_summary_total", value: "\(data.repositories.count)")
                summaryRow(label: "profile_summary_original", value: "\(data.originalRepos.count)")
                summaryRow(label: "profile_summary_active", value: "\(data.activeRepos.count)")
                summaryRow(label: "profile_summary_maintenance", value: "\(Int(data.averageMaintenanceScore))%")
                if data.starToRepoRatio > 0 {
                    summaryRow(label: "profile_summary_stars_per_repo", value: String(format: "%.1f", data.starToRepoRatio))
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(LocalizedStringKey(label))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
    
    private func languageBreakdown(_ stats: LanguageStatistics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("profile_languages")
                    .font(.headline)
                Spacer()
                Text("profile_diversity")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if stats.languages.isEmpty {
                Text("profile_no_languages")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            } else {
                ForEach(stats.languages.prefix(5)) { lang in
                    HStack {
                        Circle()
                            .fill(Color(hex: lang.colorHex) ?? .gray)
                            .frame(width: 12, height: 12)
                        
                        Text(lang.name)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("\(String(format: "%.1f", lang.percentage))%")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Error View
    
    private func errorView(_ error: ProfileError) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text(LocalizedStringKey(error.errorDescription ?? "common_error"))
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            Button(action: { viewModel.refresh() }) {
                Label("common_try_again", systemImage: "arrow.clockwise")
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(.top, 60)
    }
    
    // MARK: - Helper Methods
    
    private func formatNumber(_ number: Int) -> String {
        if number >= 1000 {
            return String(format: "%.1fK", Double(number) / 1000)
        }
        return "\(number)"
    }
    
    private func colorForStatus(_ status: UserActivityStatus) -> Color {
        switch status {
        case .veryActive: return .green
        case .active: return .blue
        case .moderate: return .yellow
        case .inactive: return .orange
        case .dormant: return .red
        }
    }
    
    private func shareProfile() {
        // TODO: Implement sharing
    }
}

// MARK: - Color Extension

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProfileScreen(username: "sameernadaf")
            .environmentObject(AppRouter())
    }
}
