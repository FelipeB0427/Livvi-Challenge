//
//  APIError.swift
//  LivviApp
//
//  Created by Felipe on 01/04/26.
//

import Foundation

// Define a custom error type for API-related errors
struct APIError: Decodable, Error {
    let code: String
    let description: String
    let fieldErrors: [FieldError]?
}

struct FieldError: Decodable {
    let field: String
    let message: String
}

// Define internal errors for the networking layer
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, APIError?)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .invalidResponse:
            return "Unexpected response from the server."
        case .httpError(_, let apiError):
            return apiError?.description ?? "An HTTP error occurred."
        case .decodingError(let error):
            return "Failed to decode the response: \(error.localizedDescription)"
        }
    }
}
