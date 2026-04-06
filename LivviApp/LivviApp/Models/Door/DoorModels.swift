//
//  DoorModels.swift
//  LivviApp
//
//  Created by Felipe on 05/04/26.
//

import Foundation

struct PaginateResponse<T: Decodable>: Decodable {
    let items: [T]
    let page: PageInfo
}

struct PageInfo: Decodable {
    let number: Int
    let size: Int
    let totalItems: Int
    let totalPages: Int
}

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
