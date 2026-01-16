//
//  HealthScoreCard.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import SwiftUI

/// Card displaying the profile health score with breakdown
struct HealthScoreCard: View {
    
    // MARK: - Properties
    
    let healthScore: HealthScore
    @State private var showBreakdown = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            // Main score
            HStack(alignment: .center, spacing: 20) {
                scoreCircle
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Profile Health")
                        .font(.headline)
                    
                    Text(healthScore.rating)
                        .font(.subheadline)
                        .foregroundColor(scoreColor)
                    
                    Button(action: { withAnimation { showBreakdown.toggle() } }) {
                        HStack(spacing: 4) {
                            Text(showBreakdown ? "Hide Details" : "Show Details")
                            Image(systemName: showBreakdown ? "chevron.up" : "chevron.down")
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
                
                Spacer()
            }
            
            // Breakdown
            if showBreakdown {
                VStack(spacing: 12) {
                    Divider()
                    
                    ForEach(healthScore.breakdown.all) { category in
                        categoryRow(category)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding()
        .background(scoreColor.opacity(0.1))
        .cornerRadius(16)
    }
    
    // MARK: - Score Circle
    
    private var scoreCircle: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(scoreColor.opacity(0.2), lineWidth: 8)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: Double(healthScore.overall) / 100)
                .stroke(
                    scoreColor,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1), value: healthScore.overall)
            
            // Score text
            VStack(spacing: 0) {
                Text("\(healthScore.overall)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(scoreColor)
                
                Text("/ 100")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 80, height: 80)
    }
    
    // MARK: - Category Row
    
    private func categoryRow(_ category: CategoryScore) -> some View {
        VStack(spacing: 4) {
            HStack {
                Text(category.name)
                    .font(.subheadline)
                
                Spacer()
                
                Text("\(category.score)")
                    .font(.subheadline.bold())
                    .foregroundColor(colorForScore(category.score))
                
                Text("× \(Int(category.weight * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(colorForScore(category.score))
                        .frame(width: geo.size.width * Double(category.score) / 100, height: 4)
                        .cornerRadius(2)
                        .animation(.easeOut(duration: 0.5), value: category.score)
                }
            }
            .frame(height: 4)
            
            HStack {
                Text(category.details)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
    }
    
    // MARK: - Helpers
    
    private var scoreColor: Color {
        colorForScore(healthScore.overall)
    }
    
    private func colorForScore(_ score: Int) -> Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .blue
        case 40..<60: return .yellow
        case 20..<40: return .orange
        default: return .red
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        HealthScoreCard(
            healthScore: HealthScore(
                overall: 72,
                breakdown: ScoreBreakdown(
                    activity: CategoryScore(name: "Activity", score: 80, weight: 0.30, details: "Active contributor"),
                    repositoryQuality: CategoryScore(name: "Repository Quality", score: 65, weight: 0.25, details: "Avg maintenance: 65%"),
                    community: CategoryScore(name: "Community", score: 70, weight: 0.20, details: "Growing presence"),
                    profileCompleteness: CategoryScore(name: "Profile", score: 83, weight: 0.15, details: "83% complete"),
                    languageDiversity: CategoryScore(name: "Languages", score: 60, weight: 0.10, details: "Versatile")
                )
            )
        )
    }
    .padding()
    .background(Color(.systemGray6))
}
