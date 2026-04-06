//
//  NetworkService.swift
//  LivviApp
//
//  Created by Felipe on 02/04/26.
//

import Foundation

protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

final class NetworkService: NetworkServiceProtocol {
    private let urlSession: URLSession
    private let authStore: KeychainAuthStore
    
    init(urlSession: URLSession = .shared, authStore: KeychainAuthStore = KeychainAuthStore()) {
        self.urlSession = urlSession
        self.authStore = authStore
    }
    
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
