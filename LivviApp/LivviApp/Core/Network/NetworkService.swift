//
//  NetworkService.swift
//  LivviApp
//
//  Created by Felipe on 02/04/26.
//

import Foundation

/// NetworkServiceProtocol defines an abstraction for performing typed network requests.
///
/// Use this protocol in places where you want to inject a mock or alternative implementation
/// for testing. Implementations should execute the HTTP request described by `Endpoint` and
/// decode the response into a `Decodable` model.
///
/// - SeeAlso: `NetworkService`, `Endpoint`, `APIError`
protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

/// NetworkService performs HTTP requests described by `Endpoint` values and decodes responses.
///
/// It optionally injects a bearer token from `KeychainAuthStore` when the endpoint requires
/// authentication. Decoding and HTTP errors are mapped to `NetworkError` cases.
///
/// - Note: Decoding errors are wrapped in `NetworkError.decodingError` and HTTP errors in
/// `NetworkError.httpError`.
final class NetworkService: NetworkServiceProtocol {
    private let urlSession: URLSession
    private let authStore: KeychainAuthStore
    
    /// Create a new NetworkService instance.
    ///
    /// - Parameters:
    ///   - urlSession: The URLSession used to perform requests. Defaults to `URLSession.shared`.
    ///   - authStore: A `KeychainAuthStore` instance used to read saved tokens for authenticated requests.
    init(urlSession: URLSession = .shared, authStore: KeychainAuthStore = KeychainAuthStore()) {
        self.urlSession = urlSession
        self.authStore = authStore
    }
    
    /// Sends a request defined by `Endpoint` and returns a decoded value of type `T`.
    ///
    /// - Parameter endpoint: The endpoint describing the request (method, path, body).
    /// - Throws: `NetworkError.invalidURL` if the endpoint cannot produce a URLRequest;
    ///   `NetworkError.httpError` for non-2xx responses; `NetworkError.decodingError` when decoding fails;
    ///   `NetworkError.invalidResponse` for non-HTTP responses.
    /// - Returns: A decoded model of type `T` conforming to `Decodable`.
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard var request = endpoint.urlRequest else {
            throw NetworkError.invalidURL
        }
        
        // Token interception
        if endpoint.requiresAuth, let token = authStore.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // Success verification
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorPayload = String(data: data, encoding: .utf8) {
                print("🚨 MOTIVO DO ERRO \(httpResponse.statusCode): \(errorPayload)")
            }
            
            let apiError = try? JSONDecoder().decode(APIError.self, from: data)
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, apiError)
        }
        
        // Decode the response
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("🚨 DECODE ERROR: \(error)")
            
            if let rawJSON = String(data: data, encoding: .utf8) {
                print("📦 JSON THAT MAKE THE ERROR:\n\(rawJSON)")
                print("----------------------------------------")
            }
            
            throw NetworkError.decodingError(error)
        }
    }
}
