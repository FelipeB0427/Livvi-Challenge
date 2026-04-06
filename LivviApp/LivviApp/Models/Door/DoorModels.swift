//
//  DoorModels.swift
//  LivviApp
//
//  Created by Felipe on 05/04/26.
//

import Foundation

/// Generic paginated response returned by the API.
struct PaginatedResponse<T: Decodable>: Decodable {
    let content: [T]
    let page: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
}

/// Represents a door managed by the Livvi backend.
struct Door: Decodable, Identifiable {
    let id: Int
    let serial: String
    let lockMac: String
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let battery: Int
}
