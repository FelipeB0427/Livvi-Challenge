//
//  BLEEventParser.swift
//  LivviApp
//
//  Created by Felipe on 06/04/26.
//

import Foundation

enum BLEParseError: Error {
    case invalidBase64
    case insufficientData
}

/// BLEEventParser parses base64-encoded BLE event payloads produced by the door devices.
///
/// The parser expects a compact binary format where the first 4 bytes represent a
/// little-endian Unix timestamp offset from `deviceEpoch`, followed by a single `logCode` byte
/// describing the event and an optional payload whose length is encoded in the high nibble
/// of the `logCode`.
///
/// - Note: The parser assumes the device epoch defined by `deviceEpoch`.
/// - SeeAlso: `ParsedBLEEvent`, `BLEEventType`
class BLEEventParser {
    public static let deviceEpoch: Date = {
        var components = DateComponents()
        
        components.year = 2026
        components.month = 1
        components.day = 1
        components.timeZone = TimeZone(secondsFromGMT: 0)
        
        return Calendar.current.date(from: components)!
    }()
    
    /// Parse a base64 encoded event string into a `ParsedBLEEvent`.
    ///
    /// - Parameter base64String: The base64-encoded bytes returned by the API for a single event.
    /// - Throws: `BLEParseError.invalidBase64` when the input is not valid base64; `BLEParseError.insufficientData`
    ///           when the decoded buffer does not contain the minimum required fields.
    /// - Returns: A `ParsedBLEEvent` containing a decoded timestamp, human-friendly event type and payload details.
    func parse(base64String: String) throws -> ParsedBLEEvent {
        guard let data = Data(base64Encoded: base64String) else {
            throw BLEParseError.invalidBase64
        }
        
        guard data.count >= 5 else {
            throw BLEParseError.insufficientData
        }
        
        let tsRaw = data[0...3].withUnsafeBytes { $0.load(as: UInt32.self) }
        let eventDate = Self.deviceEpoch.addingTimeInterval(TimeInterval(tsRaw))
        let logCode = data[4]
        let payloadLen = Int((logCode >> 4) & 0x0F)
        let typeId = logCode & 0x0F
        let payloadEnd = 5 + payloadLen
        
        guard data.count >= payloadEnd else {
            throw BLEParseError.insufficientData
        }
        
        let payloadData = data[5..<payloadEnd]
        let eventType = BLEEventType(rawValue: logCode)
        let eventName = eventType?.description ?? "Unknown (Code: \(String(format: "0x%02X", logCode)))"
        let payloadDetails = processPayload(data: payloadData, logCode: logCode)
        
        return ParsedBLEEvent(timestamp: eventDate, eventType: eventName, payloadDetails: payloadDetails)
    }
    
    private func processPayload(data: Data, logCode: UInt8) -> String {
        if data.isEmpty {
            return "No additional data"
        }
        
        // 1. Convert the Data "slice" into a Byte Array to ensure the index starts at 0
        let bytes = [UInt8](data)
        
        switch logCode {
        case 0x13: // Battery Low
            let level = bytes[0]
            return "Battery Level: \(level)%"
        case 0x50, 0x51: // Unlock / Unlock Denied
            guard bytes.count == 5 else { return "Invalid payload" }
            
            // Now accessing index 0 is 100% safe
            let mode = bytes[0]
            
            // 2. Repack the 4 bytes of the ID to extract the Little-Endian UInt32
            let permissionId = Data(bytes[1...4]).withUnsafeBytes { $0.load(as: UInt32.self) }
            
            let modeName = getPermissionModeName(mode)
            return "Mode: \(modeName) | Permission ID: \(permissionId)"
        default:
            // Fallback: show the raw payload in Hexadecimal
            let hexString = bytes.map { String(format: "%02X", $0) }.joined(separator: " ")
            return "Raw Payload: [\(hexString)]"
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
