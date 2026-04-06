//
//  AuthModels.swift
//  LivviApp
//
//  Created by Felipe on 05/04/26.
//

import Foundation

// MARK: - Requests

/// Request payload used to create a new user account.
struct SignUpRequest: Encodable {
    let firstName: String
    let lastName: String
    let email: String
    let password: String
}

/// Request payload used to sign in an existing user.
struct SignInRequest: Encodable {
    let email: String
    let password: String
}

// MARK: - Responses

/// Response returned by the server after a successful authentication containing a bearer token.
struct TokenResponse: Decodable {
    let token: String
}

/// Represents a user object returned by the API.
struct UserResponse: Decodable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
}
