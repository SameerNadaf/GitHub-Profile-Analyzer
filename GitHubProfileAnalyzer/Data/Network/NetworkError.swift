//
//  NetworkError.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import Foundation

// MARK: - Network Error

/// Typed network errors with user-friendly messages and recovery options
enum NetworkError: LocalizedError, Equatable {
    
    // MARK: - Cases
    
    /// No internet connection
    case noConnection
    
    /// Request timed out
    case timeout
    
    /// Invalid URL construction
    case invalidURL(String)
    
    /// Server returned an error status code
    case serverError(statusCode: Int, message: String?)
    
    /// Failed to decode response
    case decodingError(String)
    
    /// Request was cancelled
    case cancelled
    
    /// Rate limit exceeded
    case rateLimitExceeded(resetDate: Date?)
    
    /// Resource not found (404)
    case notFound(resource: String)
    
    /// Unauthorized - requires authentication
    case unauthorized
    
    /// Unknown error
    case unknown(String)
    
    // MARK: - LocalizedError
    
    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .serverError(let statusCode, let message):
            if let message = message {
                return "Server error (\(statusCode)): \(message)"
            }
            return "Server error: \(statusCode)"
        case .decodingError(let detail):
            return "Failed to process response: \(detail)"
        case .cancelled:
            return "Request was cancelled"
        case .rateLimitExceeded(let resetDate):
            if let date = resetDate {
                let formatter = RelativeDateTimeFormatter()
                let relative = formatter.localizedString(for: date, relativeTo: Date())
                return "Rate limit exceeded. Try again \(relative)"
            }
            return "Rate limit exceeded. Please try again later"
        case .notFound(let resource):
            return "\(resource) not found"
        case .unauthorized:
            return "Authentication required"
        case .unknown(let message):
            return message
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .noConnection:
            return "Check your internet connection and try again"
        case .timeout:
            return "The server took too long to respond. Try again later"
        case .rateLimitExceeded:
            return "GitHub limits API requests. Sign in for higher limits"
        case .notFound:
            return "Double-check the username and try again"
        case .unauthorized:
            return "Sign in with your GitHub account"
        default:
            return nil
        }
    }
    
    // MARK: - Convenience
    
    /// Whether this error is recoverable by retrying
    var isRetryable: Bool {
        switch self {
        case .noConnection, .timeout:
            return true
        case .serverError(let statusCode, _):
            return statusCode >= 500
        default:
            return false
        }
    }
    
    // MARK: - Factory Methods
    
    /// Create from URLError
    static func from(_ urlError: URLError) -> NetworkError {
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .noConnection
        case .timedOut:
            return .timeout
        case .cancelled:
            return .cancelled
        default:
            return .unknown(urlError.localizedDescription)
        }
    }
    
    /// Create from HTTP status code
    static func from(statusCode: Int, data: Data?) -> NetworkError? {
        switch statusCode {
        case 200...299:
            return nil // Success
        case 401:
            return .unauthorized
        case 403:
            // Check if rate limited
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = json["message"] as? String,
               message.lowercased().contains("rate limit") {
                return .rateLimitExceeded(resetDate: nil)
            }
            return .serverError(statusCode: statusCode, message: "Forbidden")
        case 404:
            return .notFound(resource: "Resource")
        case 500...599:
            return .serverError(statusCode: statusCode, message: "Internal server error")
        default:
            return .serverError(statusCode: statusCode, message: nil)
        }
    }
}
