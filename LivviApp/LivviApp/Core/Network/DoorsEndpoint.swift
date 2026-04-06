//
//  DoorsEndpoint.swift
//  LivviApp
//
//  Created by Felipe on 05/04/26.
//

import Foundation

enum DoorsEndpoint: Endpoint {
    case list(page: Int, pageSize: Int)
    case find(name: String, page: Int, pageSize: Int)
    
    var path: String {
        switch self {
        case .list:
            return "/doors"
        case .find:
            return "/doors/find"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var headers: [String : String] {
        return [:]
    }
    
    var body: Data? {
        return nil
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .list(let page, let pageSize):
            return [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "pageSize", value: String(pageSize))
            ]
        case .find(let name, let page, let pageSize):
            return [
                URLQueryItem(name: "name", value: name),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "pageSize", value: String(pageSize))
            ]
        }
    }
}
        
