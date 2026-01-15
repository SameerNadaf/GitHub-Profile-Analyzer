//
//  ShimmerView.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import SwiftUI

/// Animated shimmer effect for loading placeholders
struct ShimmerView: View {
    
    // MARK: - Properties
    
    @State private var phase: CGFloat = 0
    let cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat = 8) {
        self.cornerRadius = cornerRadius
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geo in
            Color(.systemGray5)
                .overlay(
                    LinearGradient(
                        colors: [
                            .clear,
                            Color.white.opacity(0.4),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.5)
                    .offset(x: -geo.size.width + phase * geo.size.width * 2)
                )
                .clipped()
        }
        .cornerRadius(cornerRadius)
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }
}

// MARK: - Shimmer Modifier

extension View {
    /// Apply shimmer effect to view when loading
    func shimmer(isLoading: Bool) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    ShimmerView()
                }
            }
        )
    }
}

// MARK: - Profile Skeleton

/// Skeleton loading view for profile screen
struct ProfileSkeleton: View {
    var body: some View {
        VStack(spacing: 24) {
            // Avatar
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 120, height: 120)
                .overlay(ShimmerView(cornerRadius: 60))
            
            // Name
            ShimmerView()
                .frame(width: 150, height: 24)
            
            // Username
            ShimmerView()
                .frame(width: 100, height: 16)
            
            // Bio
            VStack(spacing: 8) {
                ShimmerView()
                    .frame(height: 14)
                ShimmerView()
                    .frame(width: 200, height: 14)
            }
            
            // Stats bar
            ShimmerView()
                .frame(height: 70)
            
            // Cards
            ForEach(0..<3, id: \.self) { _ in
                ShimmerView()
                    .frame(height: 100)
            }
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        ShimmerView()
            .frame(height: 50)
        
        ProfileSkeleton()
    }
    .padding()
}
