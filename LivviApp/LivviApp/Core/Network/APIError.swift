//
//  APIError.swift
//  LivviApp
//
//  Created by Felipe on 01/04/26.
//

import Foundation

/// Represents an error object returned by the backend API.
///
/// Contains a machine-friendly `code`, a `description` for display, and optional field-level errors
/// that indicate validation problems.
struct APIError: Decodable, Error {
    let code: String
    let description: String
    let fieldErrors: [FieldError]?
}

/// FieldError maps a validation error for a specific field returned by the API.
struct FieldError: Decodable {
    let field: String
    let message: String
}

/// NetworkError enumerates common errors produced by the networking layer.
///
/// This includes invalid URL construction, unexpected responses, HTTP status errors with
/// optional `APIError` payloads, and decoding failures.
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
