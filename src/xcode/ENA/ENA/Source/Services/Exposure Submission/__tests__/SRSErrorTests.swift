//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

final class SRSErrorTests: XCTestCase {
	
	override func setUp() {
		InternetConnectivityMonitor.shared.isDeviceOnlineMock = true
	}
	
	override func tearDown() {
		InternetConnectivityMonitor.shared.isDeviceOnlineMock = false
	}
	
	func testDescription_ppacError() throws {
		// GIVEN
		let sut: SRSError = .ppacError(.submissionTooEarly)
		
		// THEN
		XCTAssertEqual(sut.description, PPACError.submissionTooEarly.description)
	}

    func testDescription_otpError() throws {
		// GIVEN
		let sut: SRSError = .otpError(.apiTokenExpired)
		
		// THEN
		XCTAssertEqual(sut.description, OTPError.apiTokenExpired.description)
    }
	
	func testDescription_srsOTPClientError() throws {
		// GIVEN
		let sut: SRSError = .srsOTPClientError
		
		// THEN
		XCTAssertEqual(sut.description, "SRS_OTP_CLIENT_ERROR")
	}

	func testDescription_srsOTPNetworkError() throws {
		// GIVEN
		let sut: SRSError = .srsOTPNetworkError
		
		// THEN
		XCTAssertEqual(sut.description, "SRS_OTP_NO_NETWORK")
	}

	func testDescription_srsOTPServerError() throws {
		// GIVEN
		let sut: SRSError = .srsOTPServerError
		
		// THEN
		XCTAssertEqual(sut.description, "SRS_OTP_SERVER_ERROR")
	}

	func testDescription_srsOTP400() throws {
		// GIVEN
		let sut: SRSError = .srsOTP400
		
		// THEN
		XCTAssertEqual(sut.description, "SRS_OTP_400")
	}

	func testDescription_srsOTP401() throws {
		// GIVEN
		let sut: SRSError = .srsOTP401
		
		// THEN
		XCTAssertEqual(sut.description, "SRS_OTP_401")
	}

	func testDescription_srsOTP403() throws {
		// GIVEN
		let sut: SRSError = .srsOTP403
		
		// THEN
		XCTAssertEqual(sut.description, "SRS_OTP_403")
	}

	func testDescription_srsSUBClientError() throws {
		// GIVEN
		let sut: SRSError = .srsSUBClientError
		
		// THEN
		XCTAssertEqual(sut.description, "SRS_SUB_CLIENT_ERROR")
	}

	func testDescription_srsSUBNoNetwork() throws {
		// GIVEN
		let sut: SRSError = .srsSUBNoNetwork
		
		// THEN
		XCTAssertEqual(sut.description, "SRS_SUB_NO_NETWORK")
	}

	func testDescription_srsSUBServerError() throws {
		// GIVEN
		let sut: SRSError = .srsSUBServerError
		
		// THEN
		XCTAssertEqual(sut.description, "SRS_SUB_SERVER_ERROR")
	}

	func testDescription_srsSUB400() throws {
		// GIVEN
		let sut: SRSError = .srsSUB400
		
		// THEN
		XCTAssertEqual(sut.description, "SRS_SUB_400")
	}

	func testDescription_srsSUB403() throws {
		// GIVEN
		let sut: SRSError = .srsSUB403
		
		// THEN
		XCTAssertEqual(sut.description, "SRS_SUB_403")
	}
	
	func testDescription_srsSUB429() throws {
		// GIVEN
		let sut: SRSError = .srsSUB429
		
		// THEN
		XCTAssertEqual(sut.description, "SRS_SUB_429")
	}
	
	func testDescription_isDeviceOnline_false_NO_NETWORK() throws {
		// GIVEN
		InternetConnectivityMonitor.shared.isDeviceOnlineMock = false
		let sut: SRSError = .srsOTPClientError
		
		// THEN
		XCTAssertEqual(sut.description, "SRS_OTP_NO_NETWORK")
	}
	
	func testSRSErrorAlert_ppacError() throws {
		// GIVEN
		let sut: SRSError = .ppacError(.submissionTooEarly)
		
		// THEN
		XCTAssertEqual(sut.srsErrorAlert, PPACError.submissionTooEarly.srsErrorAlert)
	}
	
	func testSRSErrorAlert_otpError() throws {
		// GIVEN
		let sut: SRSError = .otpError(.apiTokenExpired)
		
		// THEN
		XCTAssertEqual(sut.srsErrorAlert, OTPError.apiTokenExpired.srsErrorAlert)
	}
	
	func testSRSErrorAlert_multiple_callHotline() throws {
		// THEN
		[
			SRSError.srsOTPClientError,
			.srsOTP400,
			.srsOTP401,
			.srsOTP403,
			.srsSUBClientError,
			.srsSUB400,
			.srsSUB403
		]
		.forEach { sut in XCTAssertEqual(sut.srsErrorAlert, .callHotline) }
	}
	
	func testSRSErrorAlert_multiple_noNetwork() throws {
		// THEN
		[
			SRSError.srsOTPNetworkError,
			.srsSUBNoNetwork
		].forEach { sut in XCTAssertEqual(sut.srsErrorAlert, .noNetwork) }
	}
	
	func testSRSErrorAlert_multiple_tryAgainLater() throws {
		// THEN
		[
			SRSError.srsOTPServerError,
			.srsSUBServerError,
			.srsSUB429
		].forEach { sut in XCTAssertEqual(sut.srsErrorAlert, .tryAgainLater) }
	}
	
	func testSRSErrorAlert_isDeviceOnline_false_noNetwork() throws {
		// GIVEN
		InternetConnectivityMonitor.shared.isDeviceOnlineMock = false
		let sut: SRSError = .srsOTP400
		
		// THEN
		XCTAssertEqual(sut.srsErrorAlert, .noNetwork)
	}
}
