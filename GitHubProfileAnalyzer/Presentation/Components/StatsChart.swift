//
//  StatsChart.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import SwiftUI
import Charts

/// Bar chart comparing top repositories by various metrics
struct StatsChart: View {
    
    // MARK: - Properties
    
    let repositories: [Repository]
    @State private var selectedMetric: RepoMetric = .stars
    
    private var topRepos: [Repository] {
        let sorted: [Repository]
        switch selectedMetric {
        case .stars:
            sorted = repositories.sorted { $0.starCount > $1.starCount }
        case .forks:
            sorted = repositories.sorted { $0.forkCount > $1.forkCount }
        case .maintenance:
            sorted = repositories.sorted { $0.maintenanceScore > $1.maintenanceScore }
        }
        return Array(sorted.prefix(5))
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Top Repositories")
                    .font(.headline)
                
                Spacer()
                
                Picker("Metric", selection: $selectedMetric) {
                    ForEach(RepoMetric.allCases, id: \.self) { metric in
                        Text(metric.rawValue).tag(metric)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }
            
            if topRepos.isEmpty {
                emptyState
            } else {
                chartView
                    .frame(height: 180)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Chart View
    
    private var chartView: some View {
        Chart(topRepos) { repo in
            BarMark(
                x: .value("Value", valueFor(repo)),
                y: .value("Repo", repo.name)
            )
            .foregroundStyle(colorFor(repo))
            .cornerRadius(4)
            .annotation(position: .trailing) {
                Text("\(valueFor(repo))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel()
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.title)
                    .foregroundColor(.secondary)
                Text("No repositories")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .frame(height: 100)
    }
    
    // MARK: - Helpers
    
    private func valueFor(_ repo: Repository) -> Int {
        switch selectedMetric {
        case .stars: return repo.starCount
        case .forks: return repo.forkCount
        case .maintenance: return repo.maintenanceScore
        }
    }
    
    private func colorFor(_ repo: Repository) -> Color {
        switch selectedMetric {
        case .stars: return .yellow
        case .forks: return .blue
        case .maintenance:
            let score = repo.maintenanceScore
            if score >= 70 { return .green }
            else if score >= 40 { return .yellow }
            else { return .orange }
        }
    }
}

// MARK: - Repo Metric

enum RepoMetric: String, CaseIterable {
    case stars = "Stars"
    case forks = "Forks"
    case maintenance = "Score"
}

// MARK: - Preview

#Preview {
    StatsChart(repositories: [
        Repository(
            id: 1, name: "SwiftUI-App", fullName: "user/SwiftUI-App",
            ownerUsername: "user", description: nil, htmlURL: nil, homepage: nil,
            isFork: false, isArchived: false, isDisabled: false,
            starCount: 150, forkCount: 25, watcherCount: 10, openIssueCount: 5,
            sizeKB: 1024, primaryLanguage: "Swift", topics: [],
            createdAt: Date(), updatedAt: Date(), pushedAt: Date()
        ),
        Repository(
            id: 2, name: "Python-ML", fullName: "user/Python-ML",
            ownerUsername: "user", description: nil, htmlURL: nil, homepage: nil,
            isFork: false, isArchived: false, isDisabled: false,
            starCount: 80, forkCount: 15, watcherCount: 8, openIssueCount: 2,
            sizeKB: 512, primaryLanguage: "Python", topics: [],
            createdAt: Date(), updatedAt: Date(), pushedAt: Date()
        )
    ])
    .padding()
}
