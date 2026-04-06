//
//  AuthEndpoint.swift
//  LivviApp
//
//  Created by Felipe on 05/04/26.
//

import Foundation

enum AuthEndpoint: Endpoint {
    case signUp(SignUpRequest)
    case signIn(SignInRequest)
    
    var path: String {
        switch self {
        case .signUp: return "/auth/signup"
        case .signIn: return "/auth/signin"
        }
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var headers: [String : String] {
        // No auth token needed for sign up/sign in
        return [:]
    }
    
    var body: Data? {
        let encoder = JSONEncoder()
        switch self {
        case .signUp(let request):
            return try? encoder.encode(request)
        case .signIn(let request):
            return try? encoder.encode(request)
        }
    }
    
    var queryItems: [URLQueryItem] {
        return []
    }
}
