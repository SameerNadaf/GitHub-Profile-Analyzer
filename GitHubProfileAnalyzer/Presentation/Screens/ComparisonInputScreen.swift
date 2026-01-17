//
//  ComparisonInputScreen.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import SwiftUI

/// Screen for entering two usernames to compare
struct ComparisonInputScreen: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var router: AppRouter
    
    @State private var username1 = ""
    @State private var username2 = ""
    @State private var isAnalyzing = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 24) {
            
            Text("Compare Profiles")
                .font(.largeTitle)
                .bold()
                .padding(.top, 40)
            
            Text("See who has better stats, health scores, and more.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                // First username field with card styling
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.secondary)
                    TextField("First Username", text: $username1)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // VS badge
                Text("VS")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.blue)
                    .clipShape(Circle())
                
                // Second username field with card styling
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.secondary)
                    TextField("Second Username", text: $username2)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Button(action: startComparison) {
                HStack {
                    Text("Compare Now")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isValid ? Color.blue : Color(.systemGray4))
                .foregroundColor(isValid ? .white : .secondary)
                .cornerRadius(12)
            }
            .disabled(!isValid)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .navigationTitle("Comparison")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Computed Properties
    
    private var isValid: Bool {
        !username1.trimmingCharacters(in: .whitespaces).isEmpty &&
        !username2.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // MARK: - Actions
    
    private func startComparison() {
        guard isValid else { return }
        let u1 = username1.trimmingCharacters(in: .whitespaces)
        let u2 = username2.trimmingCharacters(in: .whitespaces)
        
        router.navigate(to: .comparison(usernames: [u1, u2]))
    }
}

#Preview {
    NavigationStack {
        ComparisonInputScreen()
            .environmentObject(AppRouter())
    }
}
