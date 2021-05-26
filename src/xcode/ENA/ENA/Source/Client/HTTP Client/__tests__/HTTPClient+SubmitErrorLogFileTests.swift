////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class HTTPClientSubmitErrorLogFileTests: CWATestCase {
	
	func testGIVEN_ErrorLog_WHEN_Submit_THEN_HappyCase_LogUploadResponseIsReturned() throws {
		// GIVEN
		let dummyData = Data("Iron man".utf8)
		let expectedResponse: LogUploadResponse = LogUploadResponse(id: "ID", hash: "Hash")

		let jsonEncoder = JSONEncoder()
		let encoded = try jsonEncoder.encode(expectedResponse)

		let stack = MockNetworkStack(
			httpStatus: 201,
			responseData: encoded
		)

		let expectation = self.expectation(description: "completion handler is called without an error")
		let otp = "OTPFake"

		// WHEN
		var mockResponse: LogUploadResponse?
		HTTPClient.makeWith(mock: stack).submit(errorLogFile: dummyData, otpEls: otp, completion: { result in
			switch result {
			case let .success(response):
				mockResponse = response
			case let .failure(error):
				XCTFail("Test should not fail. Error: \(error.localizedDescription)")
			}
			expectation.fulfill()
			
		})

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertNotNil(mockResponse)
		XCTAssertEqual(expectedResponse.id, mockResponse?.id)
		XCTAssertEqual(expectedResponse.hash, mockResponse?.hash)
	}
	
	func testGIVEN_ErrorLog_WHEN_Submit_THEN_InternalServerError() throws {
		// GIVEN
		
		let stack = MockNetworkStack(
			httpStatus: 500,
			responseData: Data()
		)

		let expectation = self.expectation(description: "completion handler is called with an error")
		let otp = "OTPFake"

		// WHEN
		var errorResponse: ELSError?
		HTTPClient.makeWith(mock: stack).submit(errorLogFile: Data(), otpEls: otp, completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not succeed.")
			case let .failure(error):
				errorResponse = error
			}
			expectation.fulfill()
			
		})

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertEqual(errorResponse, ELSError.responseError(500))
	}
	
	func testGIVEN_ErrorLog_WHEN_Submit_THEN_OtherStatusCode() throws {
		// GIVEN
		
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data()
		)

		let expectation = self.expectation(description: "completion handler is called with an error")
		let otp = "OTPFake"

		// WHEN
		var errorResponse: ELSError?
		HTTPClient.makeWith(mock: stack).submit(errorLogFile: Data(), otpEls: otp, completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not succeed.")
			case let .failure(error):
				errorResponse = error
			}
			expectation.fulfill()
			
		})

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertEqual(errorResponse, ELSError.responseError(200))
	}
	
	func testGIVEN_ErrorLog_WHEN_Submit_THEN_ResponseIsNil() throws {
		// GIVEN
		
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: nil
		)

		let expectation = self.expectation(description: "completion handler is called with an error")
		let otp = "OTPFake"

		// WHEN
		var errorResponse: ELSError?
		HTTPClient.makeWith(mock: stack).submit(errorLogFile: Data(), otpEls: otp, completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not succeed.")
			case let .failure(error):
				errorResponse = error
			}
			expectation.fulfill()
			
		})

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertEqual(errorResponse, .defaultServerError(URLSession.Response.Failure.noResponse))
	}
}
