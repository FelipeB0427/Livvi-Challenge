//
//  EventsEndpoint.swift
//  LivviApp
//
//  Created by Felipe on 06/04/26.
//

import Foundation

/// Endpoints for fetching events related to a door.
enum EventsEndpoint: Endpoint {
    case rawEvents(doorId: Int, page: Int, size: Int)
    
    var path: String {
        switch self {
        case .rawEvents(let doorId, _, _):
            return "/doors/\(doorId)/events"
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
        case .rawEvents(_, let page, let size):
            return [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "size", value: String(size))
            ]
        }
    }
}
