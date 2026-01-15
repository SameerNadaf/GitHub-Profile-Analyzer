//
//  RepositoryMapper.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import Foundation

// MARK: - Repository Mapper

/// Maps RepositoryDTO to Repository domain model
enum RepositoryMapper {
    
    /// Convert single RepositoryDTO to domain model
    static func toDomain(_ dto: RepositoryDTO) -> Repository {
        Repository(
            id: dto.id,
            name: dto.name,
            fullName: dto.fullName,
            ownerUsername: dto.owner.login,
            description: dto.description?.trimmingCharacters(in: .whitespacesAndNewlines),
            htmlURL: URL(string: dto.htmlUrl),
            homepage: parseURL(dto.homepage),
            isFork: dto.fork,
            isArchived: dto.archived ?? false,
            isDisabled: dto.disabled ?? false,
            starCount: dto.stargazersCount,
            forkCount: dto.forksCount,
            watcherCount: dto.watchersCount,
            openIssueCount: dto.openIssuesCount,
            sizeKB: dto.size,
            primaryLanguage: dto.language,
            topics: dto.topics ?? [],
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt,
            pushedAt: dto.pushedAt
        )
    }
    
    /// Convert array of RepositoryDTOs to domain models
    static func toDomain(_ dtos: [RepositoryDTO]) -> [Repository] {
        dtos.map { toDomain($0) }
    }
    
    /// Parse URL string handling empty strings
    private static func parseURL(_ string: String?) -> URL? {
        guard let urlString = string?.trimmingCharacters(in: .whitespaces),
              !urlString.isEmpty else {
            return nil
        }
        return URL(string: urlString)
    }
}

// MARK: - Language Mapper

/// Maps language data to LanguageStatistics
enum LanguageMapper {
    
    /// Create language statistics from repository language bytes
    /// - Parameters:
    ///   - languageBytes: Dictionary mapping language name to byte count
    ///   - repoCounts: Optional dictionary mapping language to repo count
    static func toStatistics(
        languageBytes: [String: Int],
        repoCounts: [String: Int]? = nil
    ) -> LanguageStatistics {
        let totalBytes = languageBytes.values.reduce(0, +)
        guard totalBytes > 0 else {
            return LanguageStatistics(languages: [])
        }
        
        let languages = languageBytes
            .sorted { $0.value > $1.value }
            .map { name, bytes in
                LanguageUsage(
                    name: name,
                    bytes: bytes,
                    percentage: Double(bytes) / Double(totalBytes) * 100,
                    repoCount: repoCounts?[name] ?? 0
                )
            }
        
        return LanguageStatistics(languages: languages)
    }
    
    /// Aggregate language statistics from multiple repositories
    static func aggregateFromRepositories(_ repositories: [Repository]) -> LanguageStatistics {
        // Count repos per language
        var repoCounts: [String: Int] = [:]
        for repo in repositories {
            if let lang = repo.primaryLanguage {
                repoCounts[lang, default: 0] += 1
            }
        }
        
        // For accurate byte counts, we'd need to fetch each repo's languages
        // For now, use repo counts as a proxy (will be enhanced with actual API data)
        let languageBytes = repoCounts.mapValues { $0 * 1000 } // Placeholder
        
        return toStatistics(languageBytes: languageBytes, repoCounts: repoCounts)
    }
}
