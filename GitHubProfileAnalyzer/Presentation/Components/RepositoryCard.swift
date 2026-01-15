//
//  RepositoryCard.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import SwiftUI

/// Reusable card component for displaying repository information
struct RepositoryCard: View {
    
    // MARK: - Properties
    
    let repository: Repository
    var showOwner: Bool = false
    var onTap: (() -> Void)?
    
    // MARK: - Body
    
    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack(spacing: 8) {
                    // Language color dot
                    if let language = repository.primaryLanguage {
                        Circle()
                            .fill(languageColor(for: language))
                            .frame(width: 12, height: 12)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text(repository.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            if repository.isFork {
                                Image(systemName: "tuningfork")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            if repository.isArchived {
                                Text("Archived")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.orange.opacity(0.2))
                                    .foregroundColor(.orange)
                                    .cornerRadius(4)
                            }
                        }
                        
                        if showOwner {
                            Text(repository.ownerUsername)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Activity indicator
                    activityBadge
                }
                
                // Description
                if let description = repository.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Stats row
                HStack(spacing: 16) {
                    if let language = repository.primaryLanguage {
                        Label(language, systemImage: "chevron.left.forwardslash.chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Label("\(repository.starCount)", systemImage: "star")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label("\(repository.forkCount)", systemImage: "tuningfork")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if let daysSince = repository.daysSinceLastPush {
                        Text(formatDaysSince(daysSince))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Topics
                if !repository.topics.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(repository.topics.prefix(5), id: \.self) { topic in
                                Text(topic)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Subviews
    
    private var activityBadge: some View {
        Text(repository.activityStatus.rawValue)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(colorForActivityStatus(repository.activityStatus).opacity(0.15))
            .foregroundColor(colorForActivityStatus(repository.activityStatus))
            .cornerRadius(8)
    }
    
    // MARK: - Helper Methods
    
    private func languageColor(for language: String) -> Color {
        switch language.lowercased() {
        case "swift": return Color(red: 0.94, green: 0.32, blue: 0.22)
        case "javascript": return Color(red: 0.97, green: 0.87, blue: 0.12)
        case "typescript": return Color(red: 0.19, green: 0.47, blue: 0.78)
        case "python": return Color(red: 0.22, green: 0.46, blue: 0.67)
        case "java": return Color(red: 0.69, green: 0.45, blue: 0.10)
        case "kotlin": return Color(red: 0.66, green: 0.48, blue: 1.0)
        case "go": return Color(red: 0, green: 0.68, blue: 0.85)
        case "rust": return Color(red: 0.87, green: 0.65, blue: 0.52)
        case "ruby": return Color(red: 0.8, green: 0.20, blue: 0.18)
        case "c++", "cpp": return Color(red: 0.95, green: 0.29, blue: 0.49)
        case "c#", "csharp": return Color(red: 0.14, green: 0.57, blue: 0.13)
        case "html": return Color(red: 0.89, green: 0.31, blue: 0.15)
        case "css": return Color(red: 0.34, green: 0.24, blue: 0.49)
        default: return .gray
        }
    }
    
    private func colorForActivityStatus(_ status: RepositoryActivityStatus) -> Color {
        switch status {
        case .active: return .green
        case .recent: return .blue
        case .moderate: return .yellow
        case .stale: return .orange
        case .inactive, .unknown: return .gray
        }
    }
    
    private func formatDaysSince(_ days: Int) -> String {
        switch days {
        case 0: return "Today"
        case 1: return "Yesterday"
        case 2...7: return "\(days) days ago"
        case 8...30: return "\(days / 7) weeks ago"
        case 31...365: return "\(days / 30) months ago"
        default: return "\(days / 365) years ago"
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        RepositoryCard(
            repository: Repository(
                id: 1,
                name: "GitHubProfileAnalyzer",
                fullName: "sameer/GitHubProfileAnalyzer",
                ownerUsername: "sameer",
                description: "A SwiftUI app that analyzes GitHub profiles and provides insights",
                htmlURL: URL(string: "https://github.com"),
                homepage: nil,
                isFork: false,
                isArchived: false,
                isDisabled: false,
                starCount: 125,
                forkCount: 23,
                watcherCount: 10,
                openIssueCount: 5,
                sizeKB: 1024,
                primaryLanguage: "Swift",
                topics: ["ios", "swiftui", "github-api"],
                createdAt: Date().addingTimeInterval(-365 * 24 * 60 * 60),
                updatedAt: Date(),
                pushedAt: Date().addingTimeInterval(-2 * 24 * 60 * 60)
            )
        )
    }
    .padding()
    .background(Color(.systemGray6))
}
