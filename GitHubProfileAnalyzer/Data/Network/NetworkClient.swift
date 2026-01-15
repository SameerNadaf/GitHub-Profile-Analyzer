//
//  NetworkClient.swift
//  GitHubProfileAnalyzer
//
//  Created by Sameer Nadaf on 15/01/26.
//

import Foundation

// MARK: - Network Client Protocol

/// Protocol for network client operations
/// Enables dependency injection and testing
protocol NetworkClientProtocol: Sendable {
    /// Execute a request and decode the response
    func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T
    
    /// Execute a request and return raw data
    func requestData(_ endpoint: APIEndpoint) async throws -> Data
}

// MARK: - Network Client

/// URLSession-based network client with async/await support
final class NetworkClient: NetworkClientProtocol, @unchecked Sendable {
    
    // MARK: - Properties
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    /// Rate limit information from last response
    @MainActor
    private(set) var rateLimitInfo: RateLimitInfo?
    
    // MARK: - Initialization
    
    init(session: URLSession = .shared, decoder: JSONDecoder? = nil) {
        self.session = session
        self.decoder = decoder ?? Self.defaultDecoder()
    }
    
    // MARK: - Public Methods
    
    /// Execute a request and decode the response to the specified type
    func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        let data = try await requestData(endpoint)
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            throw NetworkError.decodingError(Self.describeDecodingError(decodingError))
        }
    }
    
    /// Execute a request and return raw data
    func requestData(_ endpoint: APIEndpoint) async throws -> Data {
        let request: URLRequest
        do {
            request = try endpoint.asURLRequest()
        } catch {
            throw error
        }
        
        #if DEBUG
        logRequest(request)
        #endif
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            throw NetworkError.from(urlError)
        } catch {
            throw NetworkError.unknown(error.localizedDescription)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown("Invalid response type")
        }
        
        #if DEBUG
        logResponse(httpResponse, data: data)
        #endif
        
        // Extract rate limit info
        await updateRateLimitInfo(from: httpResponse)
        
        // Check for errors
        if let error = NetworkError.from(statusCode: httpResponse.statusCode, data: data) {
            // Enhance not found error with context
            if case .notFound = error,
               let url = request.url {
                throw NetworkError.notFound(resource: url.lastPathComponent)
            }
            throw error
        }
        
        return data
    }
    
    // MARK: - Private Methods
    
    private static func defaultDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    
    @MainActor
    private func updateRateLimitInfo(from response: HTTPURLResponse) {
        guard let limitString = response.value(forHTTPHeaderField: "X-RateLimit-Limit"),
              let limit = Int(limitString),
              let remainingString = response.value(forHTTPHeaderField: "X-RateLimit-Remaining"),
              let remaining = Int(remainingString) else {
            return
        }
        
        var resetDate: Date?
        if let resetString = response.value(forHTTPHeaderField: "X-RateLimit-Reset"),
           let resetTimestamp = TimeInterval(resetString) {
            resetDate = Date(timeIntervalSince1970: resetTimestamp)
        }
        
        rateLimitInfo = RateLimitInfo(
            limit: limit,
            remaining: remaining,
            resetDate: resetDate
        )
    }
    
    private static func describeDecodingError(_ error: DecodingError) -> String {
        switch error {
        case .keyNotFound(let key, let context):
            return "Missing key '\(key.stringValue)' at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
        case .typeMismatch(let type, let context):
            return "Type mismatch for \(type) at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
        case .valueNotFound(let type, let context):
            return "Null value for \(type) at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
        case .dataCorrupted(let context):
            return "Corrupted data at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
        @unknown default:
            return error.localizedDescription
        }
    }
    
    #if DEBUG
    private func logRequest(_ request: URLRequest) {
        print("🌐 REQUEST: \(request.httpMethod ?? "?") \(request.url?.absoluteString ?? "?")")
    }
    
    private func logResponse(_ response: HTTPURLResponse, data: Data) {
        let status = response.statusCode
        let emoji = (200...299).contains(status) ? "✅" : "❌"
        print("\(emoji) RESPONSE: \(status) - \(data.count) bytes")
    }
    #endif
}

// MARK: - Rate Limit Info

/// Information about GitHub API rate limits
struct RateLimitInfo: Equatable, Sendable {
    let limit: Int
    let remaining: Int
    let resetDate: Date?
    
    var isExhausted: Bool {
        remaining == 0
    }
    
    var percentageRemaining: Double {
        guard limit > 0 else { return 0 }
        return Double(remaining) / Double(limit)
    }
}
