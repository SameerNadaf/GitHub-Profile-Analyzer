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
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 32) {
            headerSection
            searchSection
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
        .background(
            LinearGradient(
                colors: [Color(.systemBackground), Color(.systemGray6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle("")
        .navigationBarHidden(true)
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 80))
                .foregroundStyle(.blue.gradient)
            
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
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Enter GitHub username", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .onSubmit(performSearch)
                
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
            
            Button(action: performSearch) {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                    Text("Analyze Profile")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    searchText.isEmpty
                        ? Color.gray.opacity(0.3)
                        : Color.blue.gradient
                )
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(searchText.isEmpty)
        }
    }
    
    // MARK: - Actions
    
    private func performSearch() {
        let trimmedUsername = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUsername.isEmpty else { return }
        
        router.navigate(to: .profile(username: trimmedUsername))
    }
}

// MARK: - Preview

#Preview {
    SearchScreen()
        .environmentObject(AppRouter())
}
