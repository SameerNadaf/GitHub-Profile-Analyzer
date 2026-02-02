//
//  ActivityChart.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import SwiftUI
import Charts

/// Bar chart showing repository activity over time
struct ActivityChart: View {
    
    // MARK: - Properties
    
    let repositories: [Repository]
    
    private var monthlyActivity: [MonthActivity] {
        computeMonthlyActivity()
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("activity_chart_title")
                    .font(.headline)
                
                Spacer()
                
                Text("activity_chart_last_12_months")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if monthlyActivity.isEmpty || monthlyActivity.allSatisfy({ $0.count == 0 }) {
                emptyState
            } else {
                chartView
                    .frame(height: 150)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Chart View
    
    private var chartView: some View {
        Chart(monthlyActivity) { activity in
            BarMark(
                x: .value(String(localized: "activity_chart_axis_month"), activity.month, unit: .month),
                y: .value(String(localized: "activity_chart_axis_updates"), activity.count)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [.blue, .blue.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(4)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month, count: 2)) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "chart.bar")
                    .font(.title)
                    .foregroundColor(.secondary)
                Text("activity_chart_no_activity")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .frame(height: 100)
    }
    
    // MARK: - Helpers
    
    private func computeMonthlyActivity() -> [MonthActivity] {
        let calendar = Calendar.current
        let now = Date()
        
        // Create buckets for last 12 months
        var buckets: [Date: Int] = [:]
        for i in 0..<12 {
            if let date = calendar.date(byAdding: .month, value: -i, to: now) {
                let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
                buckets[startOfMonth] = 0
            }
        }
        
        // Count repo updates per month
        for repo in repositories {
            guard let pushedAt = repo.pushedAt else { continue }
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: pushedAt))!
            if buckets[startOfMonth] != nil {
                buckets[startOfMonth]! += 1
            }
        }
        
        // Convert to array and sort
        return buckets.map { MonthActivity(month: $0.key, count: $0.value) }
            .sorted { $0.month < $1.month }
    }
}

// MARK: - Month Activity

struct MonthActivity: Identifiable {
    let id = UUID()
    let month: Date
    let count: Int
}

// MARK: - Preview

#Preview {
    ActivityChart(repositories: [])
        .padding()
}
