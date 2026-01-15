//
//  ComparisonMetricRow.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import SwiftUI

/// A row displaying a metric comparison between two users
struct ComparisonMetricRow: View {
    
    // MARK: - Properties
    
    let title: String
    let value1: String
    let value2: String
    let winner: Int? // 1 for user1, 2 for user2, nil for tie
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            // User 1 Value
            Text(value1)
                .font(.subheadline)
                .fontWeight(winner == 1 ? .bold : .regular)
                .foregroundColor(winner == 1 ? .green : .primary)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            // Title
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .center)
            
            // User 2 Value
            Text(value2)
                .font(.subheadline)
                .fontWeight(winner == 2 ? .bold : .regular)
                .foregroundColor(winner == 2 ? .green : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
