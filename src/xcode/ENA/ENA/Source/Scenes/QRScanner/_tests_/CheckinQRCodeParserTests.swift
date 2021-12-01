////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

// IMPORTANT: THESE TESTS ARE BASED ON THE CURRENT EXPECTED REGEX, WE NEED TO UPDATE THEM IF THE REGEX IS UPDATED
class CheckinQRCodeParserTests: CWATestCase {

    func testValidURL() {
		let validHostName = "https://e.coronawarn.app"
		let validVersion = "?v=1"
		let validPayload = "#CAESRggBEi1CdXJsaW5ndG9uIENvYXQgRmFjdG9yeSBXYXJlaG91c2UgQ29ycG9yYXRpb24aDzE5OTAgVGlrb2QgUGlrZSgAMAAacQgBElswWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAARzsMSy1xQhFzKTfk5gMn3n+FODdRWGxoNcpPTMrs2Ec9ejLOKkSc6ncbI1cNWlo+LdwB9CbF64UxkAhfb7oDleGhAgd3QGMXeySb/sMUUkwZMgIgcIARAHGNsK"
		let validURL = validHostName + validVersion + validPayload

		let onSuccessExpectation = expectation(description: "onSuccess called")

		let checkinQRCodeParser = CheckinQRCodeParser(
			appConfigurationProvider: CachedAppConfigurationMock()
		)
		checkinQRCodeParser.verifyQrCode(
			qrCodeString: validURL,
			onSuccess: { _ in
				onSuccessExpectation.fulfill()
			},
			onError: { _ in }
		)
		waitForExpectations(timeout: .short)
	}
	
	func testInvalidURL_noVersion() {
		let validHostName = "https://e.coronawarn.app"
		let validPayload = "#CAESJQgBEgpBZ3dheSBJbmMuGhExNTk0IERlZmZlIEF2ZW51ZSgAMAAadggBEmA4xNrp5hKJoO_yVbXfF1gS8Yc5nURhOIVLG3nUcSg8IPsI2e8JSIhg-FrHUymQ3RR80KUKb1lZjLQkfTUINUP16r6-jFDURwUlCQQi6NXCgI0rQw0a4MrVrKMbF4NzhQMaEPXDJZ2XSeO0SY43-KCQlQciBggBEAQYHA"
		let validURL = validHostName + validPayload

		let onErrorExpectation = expectation(description: "onError called")

		let checkinQRCodeParser = CheckinQRCodeParser(
			appConfigurationProvider: CachedAppConfigurationMock()
		)
		checkinQRCodeParser.verifyQrCode(
			qrCodeString: validURL,
			onSuccess: { _ in },
			onError: { error in
				XCTAssertEqual(error, .codeNotFound, "Invalid url code should be: .codeNotFound")
				onErrorExpectation.fulfill()
			}
		)
		waitForExpectations(timeout: .short)
	}
	
	func testInvalidURL_WrongHost() {
		let validHostName = "https://e.wrong.app"
		let validVersion = "?v=1"
		let validPayload = "#CAESJQgBEgpBZ3dheSBJbmMuGhExNTk0IERlZmZlIEF2ZW51ZSgAMAAadggBEmA4xNrp5hKJoO_yVbXfF1gS8Yc5nURhOIVLG3nUcSg8IPsI2e8JSIhg-FrHUymQ3RR80KUKb1lZjLQkfTUINUP16r6-jFDURwUlCQQi6NXCgI0rQw0a4MrVrKMbF4NzhQMaEPXDJZ2XSeO0SY43-KCQlQciBggBEAQYHA"
		let validURL = validHostName + validVersion + validPayload

		let onErrorExpectation = expectation(description: "onError called")

		let checkinQRCodeParser = CheckinQRCodeParser(
			appConfigurationProvider: CachedAppConfigurationMock()
		)
		checkinQRCodeParser.verifyQrCode(
			qrCodeString: validURL,
			onSuccess: { _ in },
			onError: { error in
				XCTAssertEqual(error, .codeNotFound, "Invalid url code should be: .codeNotFound")
				onErrorExpectation.fulfill()
			}
		)
		waitForExpectations(timeout: .short)
	}
	
	func testInvalidURL_WrongPayload() {
		let validHostName = "https://e.coronawarn.app"
		let validVersion = "?v=1"
		let validPayload = "#Wrong_payload"
		let validURL = validHostName + validVersion + validPayload
		let onErrorExpectation = expectation(description: "onError called")

		let checkinQRCodeParser = CheckinQRCodeParser(
			appConfigurationProvider: CachedAppConfigurationMock()
		)
		checkinQRCodeParser.verifyQrCode(
			qrCodeString: validURL,
			onSuccess: { _ in },
			onError: { error in
				XCTAssertEqual(error, .invalidVendorData, "Invalid url code should be: .invalidVendorData")
				onErrorExpectation.fulfill()
			}
		)
		waitForExpectations(timeout: .short)
	}
	
	func testValidPayload_ValidInformation() {
		let traceLocation = TraceLocation.mock(
			description: "Test",
			address: "Test",
			cryptographicSeed: cryptographicSeed(count: 16)
			)
		let onSuccessExpectation = expectation(description: "onSuccess called")

		let checkinQRCodeParser = CheckinQRCodeParser(
			appConfigurationProvider: CachedAppConfigurationMock()
		)
		checkinQRCodeParser.validateTraceLocationInformation(
			traceLocation: traceLocation,
			onSuccess: { _ in
				onSuccessExpectation.fulfill()
			},
			onError: { _ in }
		)
		waitForExpectations(timeout: .short)
	}

	func testValidPayload_InvalidDescription_EmptyString() {
		let traceLocation = TraceLocation.mock(
			description: "",
			address: "Test",
			cryptographicSeed: cryptographicSeed()
			)
		let onErrorExpectation = expectation(description: "onError called")

		let checkinQRCodeParser = CheckinQRCodeParser(
			appConfigurationProvider: CachedAppConfigurationMock()
		)
		checkinQRCodeParser.validateTraceLocationInformation(
			traceLocation: traceLocation,
			onSuccess: { _ in },
			onError: { error in
				XCTAssertEqual(error, .invalidDescription, "TraceLocation description cannot be empty!")
				onErrorExpectation.fulfill()
			}
		)
		waitForExpectations(timeout: .short)
	}
	
	func testValidPayload_InvalidAddress_EmptyString() {
		let traceLocation = TraceLocation.mock(
			description: "Test",
			address: "",
			cryptographicSeed: cryptographicSeed()
			)
		let onErrorExpectation = expectation(description: "onError called")

		let checkinQRCodeParser = CheckinQRCodeParser(
			appConfigurationProvider: CachedAppConfigurationMock()
		)
		checkinQRCodeParser.validateTraceLocationInformation(
			traceLocation: traceLocation,
			onSuccess: { _ in },
			onError: { error in
				XCTAssertEqual(error, .invalidAddress, "TraceLocation address cannot be empty!")
				onErrorExpectation.fulfill()
			}
		)
		waitForExpectations(timeout: .short)
	}
	
	func testValidPayload_InvalidDescription_Over100() {
		let traceLocation = TraceLocation.mock(
			description: "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345x",
			address: "Test",
			cryptographicSeed: cryptographicSeed()
			)
		let onErrorExpectation = expectation(description: "onError called")

		let checkinQRCodeParser = CheckinQRCodeParser(
			appConfigurationProvider: CachedAppConfigurationMock()
		)
		checkinQRCodeParser.validateTraceLocationInformation(
			traceLocation: traceLocation,
			onSuccess: { _ in },
			onError: { error in
				XCTAssertEqual(error, .invalidDescription, "TraceLocation description cannot be > 255 characters!")
				onErrorExpectation.fulfill()
			}
		)
		waitForExpectations(timeout: .short)
	}
	
	func testValidPayload_InvalidAddress_Over100() {
		let traceLocation = TraceLocation.mock(
			description: "Test",
			address: "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345x",
			cryptographicSeed: cryptographicSeed()
			)
		let onErrorExpectation = expectation(description: "onError called")

		let checkinQRCodeParser = CheckinQRCodeParser(
			appConfigurationProvider: CachedAppConfigurationMock()
		)
		checkinQRCodeParser.validateTraceLocationInformation(
			traceLocation: traceLocation,
			onSuccess: { _ in },
			onError: { error in
				XCTAssertEqual(error, .invalidAddress, "TraceLocation address cannot be > 255 characters!")
				onErrorExpectation.fulfill()
			}
		)
		waitForExpectations(timeout: .short)
	}
	
	func testValidPayload_InvalidDescription_LineBreaks() {
		let traceLocation = TraceLocation.mock(
			description: "My name is\n Bond",
			address: "Test",
			cryptographicSeed: cryptographicSeed()
			)
		let onErrorExpectation = expectation(description: "onError called")

		let checkinQRCodeParser = CheckinQRCodeParser(
			appConfigurationProvider: CachedAppConfigurationMock()
		)
		checkinQRCodeParser.validateTraceLocationInformation(
			traceLocation: traceLocation,
			onSuccess: { _ in },
			onError: { error in
				XCTAssertEqual(error, .invalidDescription, "TraceLocation description cannot have LineBreaks!")
				onErrorExpectation.fulfill()
			}
		)
		waitForExpectations(timeout: .short)
	}
	
	func testValidPayload_InvalidAddress_LineBreaks() {
		let traceLocation = TraceLocation.mock(
			description: "Test",
			address: "James\rBond",
			cryptographicSeed: cryptographicSeed()
			)
		let onErrorExpectation = expectation(description: "onError called")

		let checkinQRCodeParser = CheckinQRCodeParser(
			appConfigurationProvider: CachedAppConfigurationMock()
		)
		checkinQRCodeParser.validateTraceLocationInformation(
			traceLocation: traceLocation,
			onSuccess: { _ in },
			onError: { error in
				XCTAssertEqual(error, .invalidAddress, "TraceLocation address cannot have LineBreaks!")
				onErrorExpectation.fulfill()
			}
		)
		waitForExpectations(timeout: .short)
	}

	func testValidPayload_InvalidCryptoSeed() {
		let traceLocation = TraceLocation.mock(
			description: "Test",
			address: "Test",
			cryptographicSeed: cryptographicSeed(count: 10)
			)
		let onErrorExpectation = expectation(description: "onError called")

		let checkinQRCodeParser = CheckinQRCodeParser(
			appConfigurationProvider: CachedAppConfigurationMock()
		)
		checkinQRCodeParser.validateTraceLocationInformation(
			traceLocation: traceLocation,
			onSuccess: { _ in },
			onError: { error in
				XCTAssertEqual(error, .invalidCryptoSeed, "cryptographicSeed must be 16 bytes!")
				onErrorExpectation.fulfill()
			}
		)
		waitForExpectations(timeout: .short)
	}

	func testValidPayload_InvalidTimeStamps() {
		let now = Date()
		let oneHourAgo = Calendar.utcCalendar.date(byAdding: .hour, value: -1, to: now)
		let traceLocation = TraceLocation.mock(
			description: "Test",
			address: "Test",
			startDate: now,
			endDate: oneHourAgo,
			cryptographicSeed: cryptographicSeed(count: 16)
		)
		let onErrorExpectation = expectation(description: "onError called")

		let checkinQRCodeParser = CheckinQRCodeParser(
			appConfigurationProvider: CachedAppConfigurationMock()
		)
		checkinQRCodeParser.validateTraceLocationInformation(
			traceLocation: traceLocation,
			onSuccess: { _ in },
			onError: { error in
				XCTAssertEqual(error, .invalidTimeStamps, "startTimeStamp must be less than endTimeStamp or both should be 0")
				onErrorExpectation.fulfill()
			}
		)
		waitForExpectations(timeout: .short)
	}
	
	private func cryptographicSeed(count: Int = 16) -> Data {
		var bytes = [UInt8](repeating: 0, count: count)
		let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
		guard result == errSecSuccess else {
			Log.error("Error creating random bytes.", log: .traceLocation)
			return Data()
		}
		return Data(bytes)
	}
	
}
