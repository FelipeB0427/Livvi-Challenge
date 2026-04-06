//
//  BLEEventParser.swift
//  LivviApp
//
//  Created by Felipe on 06/04/26.
//

import Foundation

enum BLEEventError: Error {
    case invalidBase64
    case insufficientData
}

class BLEEventParser {
    public static let deviceEpoch: Date = {
        var components = DateComponents()
        
        components.year = 2026
        components.month = 1
        components.day = 1
        components.timeZone = TimeZone(secondsFromGMT: 0)
        
        return Calendar.current.date(from: components)!
    }()
    
    func parse(base64String: String) throws -> ParsedBLEEvent {
        guard let data = Data(base64Encoded: base64String) else {
            throw BLEEventError.invalidBase64
        }
        
        guard data.count >= 5 else {
            throw BLEEventError.insufficientData
        }
        
        let tsRaw = data[0...3].withUnsafeBytes { $0.load(as: UInt32.self) }
        let eventDate = Self.deviceEpoch.addingTimeInterval(TimeInterval(tsRaw))
        let logCode = data[4]
        let payloadLen = Int((logCode >> 4) & 0x0F)
        let typeId = logCode & 0x0F
        let payloadEnd = 5 + payloadLen
        
        guard data.count >= payloadEnd else {
            throw BLEEventError.insufficientData
        }
        
        let payloadData = data[5..<payloadEnd]
        let eventType = BLEEventType(rawValue: logCode)
        let eventName = eventType?.description ?? "Unknown (Code: \(String(format: "0x%02X", logCode)))"
        let payloadDetails = processPayload(data: payloadData, logCode: logCode)
        
        return ParsedBLEEvent(timestamp: eventDate, eventType: eventName, payloadDetails: payloadDetails)
    }
    
    private func processPayload(data: Data, logCode: UInt8) -> String {
        if data.isEmpty {
            return "No payload"
        }
        
        switch logCode {
        case 0x13:
            let level = data[0]
            return "Battery level: \(level)%"
        case 0x50, 0x51:
            guard data.count == 5 else { return "Invalid payload" }
            
            let mode = data[0]
            let permissionId = data[1...4].withUnsafeBytes { $0.load(as: UInt32.self) }
            let modeName = getPermissionModeName(mode)
            
            return "Mode: \(modeName) | Permission ID: \(permissionId)"
        default:
            let hexString = data.map { String(format: "%02X", $0) }.joined(separator: " ")
            
            return "Raw Payload: \(hexString)"
        }
    }
    
    private func getPermissionModeName(_ mode: UInt8) -> String {
        switch mode {
        case 0: return "ALL"
        case 1: return "CARD"
        case 2: return "PASSWORD"
        case 3: return "BOT"
        case 4: return "PASSWORD OTP"
        case 5: return "QRCODE"
        case 6: return "APP"
        case 7: return "FINGERPRINT"
        default: return "Unknown (\(mode))"
        }
    }
}
