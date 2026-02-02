//
//  LanguageChart.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import SwiftUI
import Charts

/// Donut chart showing language distribution
struct LanguageChart: View {
    
    // MARK: - Properties
    
    let languages: [LanguageUsage]
    let showLegend: Bool
    
    init(languages: [LanguageUsage], showLegend: Bool = true) {
        self.languages = languages
        self.showLegend = showLegend
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("language_chart_title")
                .font(.headline)
            
            if languages.isEmpty {
                emptyState
            } else {
                HStack(spacing: 24) {
                    // Chart
                    chartView
                        .frame(width: 120, height: 120)
                    
                    // Legend
                    if showLegend {
                        legendView
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Chart View
    
    private var chartView: some View {
        Chart(languages.prefix(6), id: \.name) { lang in
            SectorMark(
                angle: .value(String(localized: "chart_metric_label"), lang.percentage),
                innerRadius: .ratio(0.6),
                angularInset: 1
            )
            .foregroundStyle(colorForLanguage(lang.name))
            .cornerRadius(4)
        }
    }
    
    // MARK: - Legend
    
    private var legendView: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(languages.prefix(5), id: \.name) { lang in
                HStack(spacing: 8) {
                    Circle()
                        .fill(colorForLanguage(lang.name))
                        .frame(width: 10, height: 10)
                    
                    Text(lang.name)
                        .font(.caption)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(String(format: "%.0f%%", lang.percentage))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if languages.count > 5 {
                Text(String(format: String(localized: "language_chart_more_format"), languages.count - 5))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "chart.pie")
                    .font(.title)
                    .foregroundColor(.secondary)
                Text("language_chart_no_data")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .frame(height: 100)
    }
    
    // MARK: - Helpers
    
    private func colorForLanguage(_ name: String) -> Color {
        switch name.lowercased() {
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
        case "php": return Color(red: 0.47, green: 0.48, blue: 0.72)
        case "shell", "bash": return Color(red: 0.35, green: 0.77, blue: 0.35)
        default: return Color.gray
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        LanguageChart(languages: [
            LanguageUsage(name: "Swift", bytes: 50000, percentage: 45, repoCount: 10),
            LanguageUsage(name: "Python", bytes: 30000, percentage: 25, repoCount: 5),
            LanguageUsage(name: "TypeScript", bytes: 20000, percentage: 18, repoCount: 4),
            LanguageUsage(name: "JavaScript", bytes: 10000, percentage: 8, repoCount: 3),
            LanguageUsage(name: "Go", bytes: 5000, percentage: 4, repoCount: 2)
        ])
    }
    .padding()
}
