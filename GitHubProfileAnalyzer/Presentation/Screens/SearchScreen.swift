//
//  SearchScreen.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import SwiftUI

/// Main search screen for finding GitHub profiles
/// This is the app's entry point screen
struct SearchScreen: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var router: AppRouter
    @State private var searchText = ""
    @State private var recentSearches: [String] = []
    @FocusState private var isSearchFocused: Bool
    
    // MARK: - Constants
    
    private let maxRecentSearches = 5
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                headerSection
                searchSection
                
                if !recentSearches.isEmpty {
                    recentSearchesSection
                }
                
                // Compare Profiles Entry
                Button(action: { router.navigate(to: .comparisonInput) }) {
                    HStack {
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.title2)
                        VStack(alignment: .leading) {
                            Text("Compare Profiles")
                                .font(.headline)
                            Text("See who wins in stats")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                .foregroundColor(.primary)
                
                featuresPreview
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
            .padding(.bottom, 40)
        }
        .background(
            LinearGradient(
                colors: [Color(.systemBackground), Color(.systemGray6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                LoginView()
            }
        }
        .onTapGesture {
            isSearchFocused = false
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 80))
                .foregroundStyle(.blue.gradient)
                .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
            
            Text("GitHub Profile Analyzer")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("Discover insights about any GitHub profile")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var searchSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Enter GitHub username", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .focused($isSearchFocused)
                    .onSubmit(performSearch)
                    .onChange(of: searchText) { _, _ in
                        // Clear validation on typing
                    }
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
            
            // Validation feedback
            if !searchText.isEmpty {
                let validation = UsernameValidator.validate(searchText)
                if !validation.isValid, let message = validation.message {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.orange)
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                }
            }
            
            Button(action: performSearch) {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                    Text("Analyze Profile")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    isValidUsername
                        ? Color.blue
                        : Color.gray.opacity(0.3)
                )
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(!isValidUsername)
        }
    }
    
    private var isValidUsername: Bool {
        !searchText.isEmpty && UsernameValidator.validate(searchText).isValid
    }
    
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Searches")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Clear") {
                    withAnimation {
                        recentSearches.removeAll()
                    }
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            FlowLayout(spacing: 8) {
                ForEach(recentSearches, id: \.self) { username in
                    Button(action: { searchUsername(username) }) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.caption)
                            Text(username)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray5))
                        .cornerRadius(20)
                        .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    private var featuresPreview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What You'll Discover")
                .font(.headline)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                featureCard(icon: "chart.pie.fill", title: "Languages", color: .purple)
                featureCard(icon: "chart.line.uptrend.xyaxis", title: "Activity", color: .green)
                featureCard(icon: "star.fill", title: "Repo Stats", color: .orange)
                featureCard(icon: "heart.fill", title: "Health Score", color: .red)
            }
        }
    }
    
    private func featureCard(icon: String, title: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
    }
    
    // MARK: - Actions
    
    private func performSearch() {
        let trimmedUsername = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUsername.isEmpty else { return }
        
        searchUsername(trimmedUsername)
    }
    
    private func searchUsername(_ username: String) {
        // Add to recent searches
        addToRecentSearches(username)
        
        // Navigate to profile
        router.navigate(to: .profile(username: username))
        
        // Clear search field
        searchText = ""
        isSearchFocused = false
    }
    
    private func addToRecentSearches(_ username: String) {
        // Remove if already exists
        recentSearches.removeAll { $0.lowercased() == username.lowercased() }
        
        // Insert at beginning
        recentSearches.insert(username, at: 0)
        
        // Limit to max
        if recentSearches.count > maxRecentSearches {
            recentSearches = Array(recentSearches.prefix(maxRecentSearches))
        }
    }
}

// MARK: - Flow Layout

/// A simple flow layout for tags/chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        
        for (index, subview) in subviews.enumerated() {
            let position = result.positions[index]
            subview.place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }
    
    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
        
        return (CGSize(width: maxWidth, height: currentY + lineHeight), positions)
    }
}

// MARK: - Preview

#Preview {
    SearchScreen()
        .environmentObject(AppRouter())
}
