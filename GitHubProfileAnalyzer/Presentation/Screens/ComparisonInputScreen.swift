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
                TextField("First Username", text: $username1)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                Text("VS")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                TextField("Second Username", text: $username2)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
            }
            .padding()
            
            Button(action: startComparison) {
                HStack {
                    Text("Compare Now")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isValid ? Color.blue : Color.gray.opacity(0.3))
                .foregroundColor(.white)
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
