//
//  TokenStore.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import Foundation
import Security

// MARK: - Token Store Protocol

protocol TokenStoreProtocol {
    func save(token: String) throws
    func get() -> String?
    func delete() throws
}

// MARK: - Token Store

/// Securely stores the access token using the Keychain
final class TokenStore: TokenStoreProtocol {
    
    // MARK: - Properties
    
    private let service = "com.githubprofileanalyzer.auth"
    private let account = "github_access_token"
    
    // MARK: - Singleton
    
    static let shared = TokenStore()
    
    // MARK: - Init
    
    init() {}
    
    // MARK: - Public Methods
    
    /// Save token to Keychain
    func save(token: String) throws {
        let data = token.data(using: .utf8)!
        
        // Define query to find existing item
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        // Check if exists
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess {
            // Update existing
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            if updateStatus != errSecSuccess {
                throw TokenStoreError.failedToSave(status: updateStatus)
            }
        } else if status == errSecItemNotFound {
            // Add new
            let newItem: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecValueData as String: data
            ]
            let addStatus = SecItemAdd(newItem as CFDictionary, nil)
            if addStatus != errSecSuccess {
                throw TokenStoreError.failedToSave(status: addStatus)
            }
        } else {
            throw TokenStoreError.keychainError(status: status)
        }
    }
    
    /// Retrieve token from Keychain
    func get() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        
        return nil
    }
    
    /// Delete token from Keychain
    func delete() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            throw TokenStoreError.failedToDelete(status: status)
        }
    }
}

// MARK: - Token Store Error

enum TokenStoreError: LocalizedError {
    case failedToSave(status: OSStatus)
    case failedToDelete(status: OSStatus)
    case keychainError(status: OSStatus)
    
    var errorDescription: String? {
        switch self {
        case .failedToSave(let status):
            return "Failed to save token to Keychain (Status: \(status))"
        case .failedToDelete(let status):
            return "Failed to delete token from Keychain (Status: \(status))"
        case .keychainError(let status):
            return "Keychain error (Status: \(status))"
        }
    }
}
