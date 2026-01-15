//
//  ErrorHandler.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import Foundation
import SwiftUI

// MARK: - Error Handler

/// Centralized error handling and display
@MainActor
final class ErrorHandler: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentError: AppError?
    @Published var showError = false
    
    // MARK: - Singleton
    
    static let shared = ErrorHandler()
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Handle an error
    func handle(_ error: Error, context: String? = nil) {
        let appError = AppError.from(error, context: context)
        
        #if DEBUG
        print("🔴 Error: \(appError.message)")
        if let context = context {
            print("   Context: \(context)")
        }
        #endif
        
        currentError = appError
        showError = true
    }
    
    /// Clear current error
    func clear() {
        currentError = nil
        showError = false
    }
}

// MARK: - App Error

/// Unified error type for the app
struct AppError: Identifiable, Equatable {
    let id = UUID()
    let type: ErrorType
    let message: String
    let recoverySuggestion: String?
    let isRetryable: Bool
    
    enum ErrorType {
        case network
        case notFound
        case rateLimited
        case validation
        case unknown
    }
    
    var icon: String {
        switch type {
        case .network: return "wifi.slash"
        case .notFound: return "person.fill.questionmark"
        case .rateLimited: return "clock.badge.exclamationmark"
        case .validation: return "exclamationmark.triangle"
        case .unknown: return "xmark.circle"
        }
    }
    
    var color: Color {
        switch type {
        case .network: return .orange
        case .notFound: return .yellow
        case .rateLimited: return .red
        case .validation: return .yellow
        case .unknown: return .red
        }
    }
    
    static func from(_ error: Error, context: String?) -> AppError {
        if let profileError = error as? ProfileError {
            return from(profileError)
        } else if let networkError = error as? NetworkError {
            return from(networkError)
        } else {
            return AppError(
                type: .unknown,
                message: error.localizedDescription,
                recoverySuggestion: "Please try again",
                isRetryable: true
            )
        }
    }
    
    static func from(_ error: ProfileError) -> AppError {
        switch error {
        case .userNotFound(let username):
            return AppError(
                type: .notFound,
                message: "User '\(username)' not found",
                recoverySuggestion: "Double-check the username and try again",
                isRetryable: false
            )
        case .networkError(let message):
            return AppError(
                type: .network,
                message: message,
                recoverySuggestion: "Check your internet connection",
                isRetryable: true
            )
        case .rateLimited:
            return AppError(
                type: .rateLimited,
                message: "Rate limit exceeded",
                recoverySuggestion: "Sign in for higher limits or wait a few minutes",
                isRetryable: true
            )
        case .unknown(let message):
            return AppError(
                type: .unknown,
                message: message,
                recoverySuggestion: nil,
                isRetryable: true
            )
        }
    }
    
    static func from(_ error: NetworkError) -> AppError {
        AppError(
            type: error.isRetryable ? .network : .unknown,
            message: error.errorDescription ?? "Network error",
            recoverySuggestion: error.recoverySuggestion,
            isRetryable: error.isRetryable
        )
    }
}

// MARK: - Error Alert Modifier

struct ErrorAlertModifier: ViewModifier {
    @ObservedObject var errorHandler: ErrorHandler
    var onRetry: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .alert(
                "Error",
                isPresented: $errorHandler.showError,
                presenting: errorHandler.currentError
            ) { error in
                if error.isRetryable, let onRetry = onRetry {
                    Button("Retry") {
                        errorHandler.clear()
                        onRetry()
                    }
                }
                Button("OK", role: .cancel) {
                    errorHandler.clear()
                }
            } message: { error in
                VStack {
                    Text(error.message)
                    if let suggestion = error.recoverySuggestion {
                        Text(suggestion)
                            .foregroundColor(.secondary)
                    }
                }
            }
    }
}

extension View {
    func errorAlert(handler: ErrorHandler = .shared, onRetry: (() -> Void)? = nil) -> some View {
        modifier(ErrorAlertModifier(errorHandler: handler, onRetry: onRetry))
    }
}

// MARK: - Username Validator

/// Validates GitHub usernames
enum UsernameValidator {
    
    /// Validation result
    struct Result {
        let isValid: Bool
        let message: String?
    }
    
    /// Validate a username
    static func validate(_ username: String) -> Result {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return Result(isValid: false, message: "Please enter a username")
        }
        
        if trimmed.count < 1 {
            return Result(isValid: false, message: "Username is too short")
        }
        
        if trimmed.count > 39 {
            return Result(isValid: false, message: "Username is too long (max 39 characters)")
        }
        
        // GitHub username rules: alphanumeric and hyphens, no consecutive hyphens
        let pattern = "^[a-zA-Z0-9](?:[a-zA-Z0-9]|-(?=[a-zA-Z0-9])){0,38}$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(trimmed.startIndex..., in: trimmed)
        
        if regex?.firstMatch(in: trimmed, range: range) == nil {
            return Result(isValid: false, message: "Invalid username format")
        }
        
        return Result(isValid: true, message: nil)
    }
}
