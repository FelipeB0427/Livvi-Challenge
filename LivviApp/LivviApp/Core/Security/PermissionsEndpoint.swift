//
//  PermissionsEndpoint.swift
//  LivviApp
//
//  Created by Felipe on 06/04/26.
//

import Foundation

enum PermissionsEndpoint: Endpoint {
    case sync(doorId: Int, clientPublicKey: String)
    
    var path: String {
        switch self {
        case .sync(let doorId, _):
            return "/doors/\(doorId)/permissions/sync"
        }
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var headers: [String : String] {
        return [:]
    }
    
    var body: Data? {
        switch self {
        case .sync(_, let clientPublicKey):
            let payload = ["clientPublicKey": clientPublicKey]
            return try? JSONEncoder().encode(payload)
        }
    }
    
    var queryItems: [URLQueryItem] {
        return []
    }
}

struct SyncResponse: Decodable {
    let serverPublicKey: String
    let encryptedPayload: String
}
