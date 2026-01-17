//
//  RepositoryListScreen.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import SwiftUI

// MARK: - Sort Option

enum RepositorySortOption: String, CaseIterable {
    case updated = "Recently Updated"
    case stars = "Most Stars"
    case name = "Name"
    case created = "Recently Created"
    
    func sort(_ repos: [Repository]) -> [Repository] {
        switch self {
        case .updated:
            return repos.sorted { ($0.pushedAt ?? $0.updatedAt) > ($1.pushedAt ?? $1.updatedAt) }
        case .stars:
            return repos.sorted { $0.starCount > $1.starCount }
        case .name:
            return repos.sorted { $0.name.lowercased() < $1.name.lowercased() }
        case .created:
            return repos.sorted { $0.createdAt > $1.createdAt }
        }
    }
}

// MARK: - Filter Option

enum RepositoryFilterOption: String, CaseIterable {
    case all = "All"
    case original = "Original"
    case forked = "Forked"
    case active = "Active"
    case archived = "Archived"
    
    func filter(_ repos: [Repository]) -> [Repository] {
        switch self {
        case .all: return repos
        case .original: return repos.filter { !$0.isFork }
        case .forked: return repos.filter { $0.isFork }
        case .active: return repos.filter { $0.isActive }
        case .archived: return repos.filter { $0.isArchived }
        }
    }
}

// MARK: - Repository List Screen

/// Screen displaying all repositories with sorting and filtering
struct RepositoryListScreen: View {
    
    // MARK: - Properties
    
    let repositories: [Repository]
    let username: String
    var totalCount: Int? = nil
    
    @State private var loadedRepositories: [Repository]?
    @State private var isLoading = false
    @State private var sortOption: RepositorySortOption = .updated
    @State private var filterOption: RepositoryFilterOption = .all
    @State private var searchText = ""
    @State private var showSortSheet = false
    @State private var showFilterSheet = false
    
    @Environment(\.openURL) private var openURL
    
    private var allRepositories: [Repository] {
        loadedRepositories ?? repositories
    }
    
    // MARK: - Computed Properties
    
    private var filteredAndSortedRepos: [Repository] {
        var result = filterOption.filter(allRepositories)
        
        // Apply search
        if !searchText.isEmpty {
            result = result.filter { repo in
                repo.name.localizedCaseInsensitiveContains(searchText) ||
                (repo.description?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (repo.primaryLanguage?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                repo.topics.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return sortOption.sort(result)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and controls bar
            controlsBar
            
            // Repository list
            if isLoading {
                ProgressView("Loading repositories...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
            } else if filteredAndSortedRepos.isEmpty {
                emptyState
            } else {
                repositoryList
            }
        }
        .navigationTitle("Repositories")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showSortSheet = true }) {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                    Button(action: { showFilterSheet = true }) {
                        Label("Filter", systemImage: "line.3.horizontal.decrease")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showSortSheet) {
            sortSheet
        }
        .sheet(isPresented: $showFilterSheet) {
            filterSheet
        }
        .task {
            await loadRepositoriesIfNeeded()
        }
    }
    
    // MARK: - Data Loading
    
    @State private var currentPage = 1
    @State private var hasMorePages = true
    @State private var isFetchingMore = false
    
    // MARK: - Data Loading
    
    private func loadRepositoriesIfNeeded() async {
        guard repositories.isEmpty, loadedRepositories == nil else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        await fetchPage(1)
    }
    
    private func loadMore() async {
        guard !isLoading && !isFetchingMore && hasMorePages else { return }
        
        isFetchingMore = true
        defer { isFetchingMore = false }
        
        await fetchPage(currentPage + 1)
    }
    
    private func fetchPage(_ page: Int) async {
        do {
            let apiClient = GitHubAPIClient()
            let dtos = try await apiClient.fetchRepositories(username: username, page: page, perPage: 30)
            let newRepos = RepositoryMapper.toDomain(dtos)
            
            if page == 1 {
                loadedRepositories = newRepos
            } else {
                loadedRepositories?.append(contentsOf: newRepos)
            }
            
            // If we got fewer items than requested, we've reached the end
            if newRepos.count < 30 {
                hasMorePages = false
            } else {
                currentPage = page
                hasMorePages = true
            }
        } catch {
            print("Failed to load page \(page): \(error)")
            if page == 1 {
                loadedRepositories = [] 
            }
            // Stop pagination on error
            hasMorePages = false
        }
    }
    
    // MARK: - Controls Bar
    
    private var controlsBar: some View {
        VStack(spacing: 12) {
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search repositories...", text: $searchText)
                    .textInputAutocapitalization(.never)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGroupedBackground))
            .cornerRadius(10)
            
            // Active filters
            HStack {
                let countText: String = {
                    if filterOption == .all && searchText.isEmpty && sortOption == .updated, let total = totalCount {
                        return "\(total) repositories"
                    } else {
                        return "\(filteredAndSortedRepos.count) repositories"
                    }
                }()
                
                Text(countText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if filterOption != .all || sortOption != .updated {
                    HStack(spacing: 8) {
                        if filterOption != .all {
                            filterChip(filterOption.rawValue) {
                                filterOption = .all
                            }
                        }
                        
                        if sortOption != .updated {
                            filterChip("↕ \(sortOption.rawValue)") {
                                sortOption = .updated
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private func filterChip(_ text: String, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: 4) {
            Text(text)
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2)
            }
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .cornerRadius(12)
    }
    
    // MARK: - Repository List
    
    private var repositoryList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredAndSortedRepos) { repo in
                    RepositoryCard(repository: repo) {
                        if let url = repo.htmlURL {
                            openURL(url)
                        }
                    }
                }
                
                // Pagination Trigger
                if hasMorePages && filterOption == .all && searchText.isEmpty && sortOption == .updated {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .onAppear {
                            Task {
                                await loadMore()
                            }
                        }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No repositories found")
                .font(.headline)
            
            if !searchText.isEmpty {
                Text("Try a different search term")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else if filterOption != .all {
                Text("Try changing the filter")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button("Show All") {
                    filterOption = .all
                }
                .buttonStyle(.borderedProminent)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Sort Sheet
    
    private var sortSheet: some View {
        NavigationStack {
            List {
                ForEach(RepositorySortOption.allCases, id: \.self) { option in
                    Button(action: {
                        sortOption = option
                        showSortSheet = false
                    }) {
                        HStack {
                            Text(option.rawValue)
                                .foregroundColor(.primary)
                            Spacer()
                            if sortOption == option {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Sort By")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { showSortSheet = false }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Filter Sheet
    
    private var filterSheet: some View {
        NavigationStack {
            List {
                ForEach(RepositoryFilterOption.allCases, id: \.self) { option in
                    Button(action: {
                        filterOption = option
                        showFilterSheet = false
                    }) {
                        HStack {
                            Text(option.rawValue)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(option.filter(allRepositories).count)")
                                .foregroundColor(.secondary)
                            
                            if filterOption == option {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { showFilterSheet = false }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RepositoryListScreen(
            repositories: [],
            username: "SameerNadaf",
            totalCount: 150
        )
    }
}
