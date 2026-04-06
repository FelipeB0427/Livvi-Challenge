//
//  BLEEventModels.swift
//  LivviApp
//
//  Created by Felipe on 06/04/26.
//

import Foundation

struct ParsedBLEEvent: Identifiable, Equatable {
    let id = UUID()
    let timestamp: Date
    let eventType: String
    let payloadDetails: String
}

enum BLEEventType: UInt8 {
    case setup = 0x00
    case doorOpen = 0x01
    case doorClose = 0x02
    case touchUnlock = 0x03
    case scheduleStart = 0x06
    case scheduleFinish = 0x07
    case scheduleTouchCancel = 0x08
    case manufacture = 0x09
    case statusPrivate = 0x10
    case statusKey = 0x11
    case statusHalfOpen = 0x12
    case batteryLow = 0x13
    case eepromWriteError = 0x20
    case eepromCrcError = 0x21
    case configuration = 0x40
    case unlock = 0x50
    case unlockDenied = 0x51
    
    var description: String {
        switch self {
        case .setup: return "Setup"
        case .doorOpen: return "Door Open"
        case .doorClose: return "Door Close"
        case .touchUnlock: return "Touch Unlock"
        case .batteryLow: return "Battery Low"
        case .unlock: return "Unlock"
        case .unlockDenied: return "Unlock Denied"
        default: return "Unknown (\(String(format: "0x%02X", self.rawValue)))"
        }
    }
}

// MARK: - API Response Models
struct APIEvent: Decodable {
    let id: Int
    let logType: String
    let logNumber: Int
    let eventTimestamp: String
    let additionalData: [APIEventAdditionalData]
}

struct APIEventAdditionalData: Decodable {
    let parameterName: String
    let hexValue: String
    let parsedValue: String
}
