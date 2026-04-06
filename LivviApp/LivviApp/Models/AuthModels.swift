//
//  AuthModels.swift
//  LivviApp
//
//  Created by Felipe on 05/04/26.
//

import Foundation

// MARK: - Requests
struct SignUpRequest: Encodable {
    let firstName: String
    let lastName: String
    let email: String
    let password: String
}

struct SignInRequest: Encodable {
    let email: String
    let password: String
}

// MARK: - Responses
struct TokenResponse: Decodable {
    let token: String
}

struct UserResponse: Decodable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
}
