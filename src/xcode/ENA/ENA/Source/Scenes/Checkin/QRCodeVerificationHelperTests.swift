////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

// IMPORTANT: THESE TESTS ARE BASED ON THE CURRENT EXPECTED REGEX, WE NEED TO UPDATE THEM IF THE REGEX IS UPDATED
class QRCodeVerificationHelperTests: XCTestCase {

    func testValidURL() {
		let appConfig = CachedAppConfigurationMock()
		let validHostName = "https://e.coronawarn.app"
		let validVersion = "?v=1"
		let validPayload = "#CAESRggBEi1CdXJsaW5ndG9uIENvYXQgRmFjdG9yeSBXYXJlaG91c2UgQ29ycG9yYXRpb24aDzE5OTAgVGlrb2QgUGlrZSgAMAAacQgBElswWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAARzsMSy1xQhFzKTfk5gMn3n+FODdRWGxoNcpPTMrs2Ec9ejLOKkSc6ncbI1cNWlo+LdwB9CbF64UxkAhfb7oDleGhAgd3QGMXeySb/sMUUkwZMgIgcIARAHGNsK"
		let validURL = validHostName + validVersion + validPayload

		let onSuccessExpectation = expectation(description: "onSuccess called")

		let qrCodeVerificationHelper = QRCodeVerificationHelper()
		qrCodeVerificationHelper.verifyQrCode(
			qrCodeString: validURL,
			appConfigurationProvider: appConfig,
			onSuccess: { _ in
				onSuccessExpectation.fulfill()
			},
			onError: { _ in }
		)
		waitForExpectations(timeout: .short)
	}
	
	func testInvalidURL_noVersion() {
		let appConfig = CachedAppConfigurationMock()
		let validHostName = "https://e.coronawarn.app"
		let validPayload = "#CAESJQgBEgpBZ3dheSBJbmMuGhExNTk0IERlZmZlIEF2ZW51ZSgAMAAadggBEmA4xNrp5hKJoO_yVbXfF1gS8Yc5nURhOIVLG3nUcSg8IPsI2e8JSIhg-FrHUymQ3RR80KUKb1lZjLQkfTUINUP16r6-jFDURwUlCQQi6NXCgI0rQw0a4MrVrKMbF4NzhQMaEPXDJZ2XSeO0SY43-KCQlQciBggBEAQYHA"
		let validURL = validHostName + validPayload

		let onErrorExpectation = expectation(description: "onError called")

		let qrCodeVerificationHelper = QRCodeVerificationHelper()
		qrCodeVerificationHelper.verifyQrCode(
			qrCodeString: validURL,
			appConfigurationProvider: appConfig,
			onSuccess: { _ in },
			onError: { error in
				XCTAssertEqual(error, .codeNotFound, "Invalid url code should be: .codeNotFound")
				onErrorExpectation.fulfill()
			}
		)
		waitForExpectations(timeout: .short)
	}
	
	func testInvalidURL_WrongHost() {
		let appConfig = CachedAppConfigurationMock()
		let validHostName = "https://e.wrong.app"
		let validVersion = "?v=1"
		let validPayload = "#CAESJQgBEgpBZ3dheSBJbmMuGhExNTk0IERlZmZlIEF2ZW51ZSgAMAAadggBEmA4xNrp5hKJoO_yVbXfF1gS8Yc5nURhOIVLG3nUcSg8IPsI2e8JSIhg-FrHUymQ3RR80KUKb1lZjLQkfTUINUP16r6-jFDURwUlCQQi6NXCgI0rQw0a4MrVrKMbF4NzhQMaEPXDJZ2XSeO0SY43-KCQlQciBggBEAQYHA"
		let validURL = validHostName + validVersion + validPayload

		let onErrorExpectation = expectation(description: "onError called")

		let qrCodeVerificationHelper = QRCodeVerificationHelper()
		qrCodeVerificationHelper.verifyQrCode(
			qrCodeString: validURL,
			appConfigurationProvider: appConfig,
			onSuccess: { _ in },
			onError: { error in
				XCTAssertEqual(error, .codeNotFound, "Invalid url code should be: .codeNotFound")
				onErrorExpectation.fulfill()
			}
		)
		waitForExpectations(timeout: .short)
	}
	
	func testInvalidURL_WrongPayload() {
		let appConfig = CachedAppConfigurationMock()
		let validHostName = "https://e.coronawarn.app"
		let validVersion = "?v=1"
		let validPayload = "#Wrong_payload"
		let validURL = validHostName + validVersion + validPayload
		let onErrorExpectation = expectation(description: "onError called")

		let qrCodeVerificationHelper = QRCodeVerificationHelper()
		qrCodeVerificationHelper.verifyQrCode(
			qrCodeString: validURL,
			appConfigurationProvider: appConfig,
			onSuccess: { _ in },
			onError: { error in
				XCTAssertEqual(error, .invalidVendorData, "Invalid url code should be: .invalidVendorData")
				onErrorExpectation.fulfill()
			}
		)
		waitForExpectations(timeout: .short)
	}
}
