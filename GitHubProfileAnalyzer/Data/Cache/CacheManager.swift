//
//  CacheManager.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import Foundation

// MARK: - Cache Entry

/// Wrapper for cached data with expiration
struct CacheEntry<T: Codable>: Codable {
    let data: T
    let timestamp: Date
    let expiresAt: Date
    
    var isExpired: Bool {
        Date() > expiresAt
    }
    
    var age: TimeInterval {
        Date().timeIntervalSince(timestamp)
    }
}

// MARK: - Cache Manager Protocol

/// Protocol for cache operations
protocol CacheManagerProtocol: Actor {
    func get<T: Codable>(_ key: String, type: T.Type) async -> T?
    func set<T: Codable>(_ key: String, value: T, ttl: TimeInterval) async
    func remove(_ key: String) async
    func clear() async
}

// MARK: - Cache Manager

/// Generic cache manager with memory and disk layers
/// Uses actor isolation for thread safety
actor CacheManager: CacheManagerProtocol {
    
    // MARK: - Properties
    
    private var memoryCache: [String: Any] = [:]
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    /// Default TTL of 5 minutes
    static let defaultTTL: TimeInterval = 300
    
    // MARK: - Singleton
    
    static let shared = CacheManager()
    
    // MARK: - Initialization
    
    init() {
        // Get cache directory
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.cacheDirectory = cachesDirectory.appendingPathComponent("GitHubProfileAnalyzer", isDirectory: true)
        
        // Create directory if needed
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Public Methods
    
    /// Get cached value if not expired
    func get<T: Codable>(_ key: String, type: T.Type) async -> T? {
        // Check memory cache first
        if let entry = memoryCache[key] as? CacheEntry<T>, !entry.isExpired {
            return entry.data
        }
        
        // Check disk cache
        let fileURL = fileURL(for: key)
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let entry = try decoder.decode(CacheEntry<T>.self, from: data)
            
            if entry.isExpired {
                // Clean up expired entry
                try? fileManager.removeItem(at: fileURL)
                memoryCache.removeValue(forKey: key)
                return nil
            }
            
            // Restore to memory cache
            memoryCache[key] = entry
            return entry.data
        } catch {
            // Failed to decode, remove corrupted file
            try? fileManager.removeItem(at: fileURL)
            return nil
        }
    }
    
    /// Cache value with TTL
    func set<T: Codable>(_ key: String, value: T, ttl: TimeInterval = defaultTTL) async {
        let entry = CacheEntry(
            data: value,
            timestamp: Date(),
            expiresAt: Date().addingTimeInterval(ttl)
        )
        
        // Update memory cache
        memoryCache[key] = entry
        
        // Write to disk
        let fileURL = fileURL(for: key)
        do {
            let data = try encoder.encode(entry)
            try data.write(to: fileURL)
        } catch {
            // Disk write failed, memory cache still valid
            #if DEBUG
            print("⚠️ Cache write failed for key: \(key)")
            #endif
        }
    }
    
    /// Remove cached value
    func remove(_ key: String) async {
        memoryCache.removeValue(forKey: key)
        let fileURL = fileURL(for: key)
        try? fileManager.removeItem(at: fileURL)
    }
    
    /// Clear all cache
    func clear() async {
        memoryCache.removeAll()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    /// Get cache size in bytes
    func cacheSize() async -> Int64 {
        var size: Int64 = 0
        let enumerator = fileManager.enumerator(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
        
        while let fileURL = enumerator?.nextObject() as? URL {
            if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                size += Int64(fileSize)
            }
        }
        
        return size
    }
    
    // MARK: - Private Methods
    
    private func fileURL(for key: String) -> URL {
        let sanitizedKey = key.replacingOccurrences(of: "/", with: "_")
        return cacheDirectory.appendingPathComponent("\(sanitizedKey).json")
    }
}
