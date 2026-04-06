//
//  BLEEventParserTests.swift
//  LivviAppTests
//
//  Created by Felipe on 06/04/26.
//

import XCTest

@testable import LivviApp

final class BLEEventParserTests: XCTestCase {
    var sut: BLEEventParser!
    
    override func setUp() {
        super.setUp()
        sut = BLEEventParser()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testParse_ValidUnlockEvent_ShouldReturnCorrectParsedEvent() throws {
        // Arrange: Preparing the fake data the API would send
        // Simulating an Unlock event (0x50) that ocurred 16 seconds after Epoch
        // Timestamp: 16 (0x10 0x00 0x00 0x00) -> 2026-01-01T00:00:16Z
        // logCode: 0x50 -> Unlock
        // Payload Mode: 0x01 -> CARD
        // Payload Permission ID: 1234 (0xD2 0x04 0x00 0x00) em Little-Endian
        let rawBytes: [UInt8] = [16, 0, 0, 0, 0x50, 0x01, 210, 4, 0, 0]
            
        // Converting ytes to string Base64
        let base64String = Data(rawBytes).base64EncodedString()
        
        // Act: Executing the function we want to test
        let result = try sut.parse(base64String: base64String)
            
        // Assert: Validating if the code behaved as expected
        XCTAssertEqual(result.eventType, "Unlock")
        XCTAssertTrue(result.payloadDetails.contains("CARD"), "The details should be CARD")
        XCTAssertTrue(result.payloadDetails.contains("1234"), "The permission ID extracted should be 1234")
    }
    
    func testParse_InvalidBase64_ShouldThrowError() {
        // Act & Assert
        XCTAssertThrowsError(try sut.parse(base64String: "this-is-not-an-base64!@#")) { error in
            XCTAssertEqual(error as? BLEParseError, .invalidBase64)
        }
    }
    
    func testParse_InsufficientBytes_ShouldThrowError() {
        // Arrange: Sending only 2 bytes (data for timestamp and logCode is missing)
        let rawBytes: [UInt8] = [16, 0]
        let base64String = Data(rawBytes).base64EncodedString()
        
        // Act & Assert
        XCTAssertThrowsError(try sut.parse(base64String: base64String)) { error in
            XCTAssertEqual(error as? BLEParseError, .insufficientData)
        }
    }
}
