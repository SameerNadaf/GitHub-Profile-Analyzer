//
//  DependencyContainer.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import Foundation

// MARK: - Dependency Container Protocol

/// Protocol for dependency resolution
protocol DependencyContainerProtocol {
    func resolve<T>(_ type: T.Type) -> T?
}

// MARK: - Dependency Container

/// Centralized dependency injection container
/// Follows the Service Locator pattern for SwiftUI compatibility
/// while maintaining testability through protocol-based resolution
@MainActor
final class DependencyContainer: ObservableObject, DependencyContainerProtocol {
    
    // MARK: - Singleton
    
    static let shared = DependencyContainer()
    
    // MARK: - Storage
    
    private var factories: [String: () -> Any] = [:]
    private var singletons: [String: Any] = [:]
    
    // MARK: - Initialization
    
    private init() {
        registerDefaults()
    }
    
    // MARK: - Registration
    
    /// Register a factory for creating instances
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        factories[key] = factory
    }
    
    /// Register a singleton instance
    func registerSingleton<T>(_ type: T.Type, instance: T) {
        let key = String(describing: type)
        singletons[key] = instance
    }
    
    /// Register a lazy singleton (created on first access)
    func registerLazySingleton<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        factories[key] = { [weak self] in
            if let existing = self?.singletons[key] as? T {
                return existing
            }
            let instance = factory()
            self?.singletons[key] = instance
            return instance
        }
    }
    
    // MARK: - Resolution
    
    /// Resolve a dependency by type
    func resolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        
        // Check singletons first
        if let singleton = singletons[key] as? T {
            return singleton
        }
        
        // Try factory
        if let factory = factories[key], let instance = factory() as? T {
            return instance
        }
        
        return nil
    }
    
    /// Resolve a dependency, throwing if not found
    func resolveRequired<T>(_ type: T.Type) throws -> T {
        guard let instance = resolve(type) else {
            throw DependencyError.notRegistered(String(describing: type))
        }
        return instance
    }
    
    // MARK: - Default Registrations
    
    private func registerDefaults() {
        // Network Client
        registerLazySingleton(NetworkClientProtocol.self) {
            NetworkClient()
        }
        
        // GitHub API Client
        registerLazySingleton(GitHubAPIClientProtocol.self) {
            GitHubAPIClient()
        }
        
        // Use Cases
        register(FetchProfileUseCaseProtocol.self) {
            FetchProfileUseCase()
        }
    }
    
    // MARK: - Testing Support
    
    /// Reset container for testing
    func reset() {
        factories.removeAll()
        singletons.removeAll()
        registerDefaults()
    }
}

// MARK: - Dependency Error

enum DependencyError: LocalizedError {
    case notRegistered(String)
    
    var errorDescription: String? {
        switch self {
        case .notRegistered(let type):
            return "Dependency not registered: \(type)"
        }
    }
}

// MARK: - Property Wrapper for Dependency Injection

@propertyWrapper
struct Injected<T> {
    private var dependency: T?
    
    var wrappedValue: T {
        get {
            guard let dep = dependency else {
                fatalError("Dependency \(T.self) not resolved. Call resolve() first.")
            }
            return dep
        }
        set {
            dependency = newValue
        }
    }
    
    init() {
        // Will be resolved lazily on first access
        self.dependency = nil
    }
}
