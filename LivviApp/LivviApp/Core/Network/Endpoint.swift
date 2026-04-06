//
//  Endpoint.swift
//  LivviApp
//
//  Created by Felipe on 01/04/26.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var body: Data? { get }
    var queryItems: [URLQueryItem] { get }
    var requiresAuth: Bool { get }
}

extension Endpoint {
    var baseURL: String {
        return "https://hiring-api.samba.dev.assaabloyglobalsolutions.net"
    }
    
    var requiresAuth: Bool {
        return true
    }
    
    var urlRequest: URLRequest? {
        guard let url = URL(string: baseURL)?.appendingPathComponent(path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))) else {
            return nil
        }
        
        var components = URLComponents(string: baseURL)
        components?.path = path
        
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        
        guard let finalURL = components?.url else { return nil }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        // Add headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add specific headers from the endpoint, if exists
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
}
