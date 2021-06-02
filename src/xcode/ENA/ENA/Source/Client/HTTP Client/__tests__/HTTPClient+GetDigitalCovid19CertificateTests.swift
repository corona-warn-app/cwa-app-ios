////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class HTTPClientGetDigitalCovid19CertificateTests: CWATestCase {
	
	func testGIVEN_RegistrationToken_WHEN_HappyCase_THEN_DCCResponseIsReturned() throws {
		// GIVEN
		let registrationToken = "someToken"
		
		let expectedResponse = DCCResponse(
			dek: "someKey",
			dcc: "someCOSE"
		)
		let jsonEncoder = JSONEncoder()
		let encoded = try jsonEncoder.encode(expectedResponse)
		
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: encoded
		)
		
		let expectation = self.expectation(description: "test should succeed with DCCResponse")
		var mockResponse: DCCResponse?
		
		// WHEN
		HTTPClient.makeWith(mock: stack).getDigitalCovid19Certificate(
			registrationToken: registrationToken,
			isFake: false,
			completion: { result in
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
		XCTAssertEqual(expectedResponse, mockResponse ?? DCCResponse(dek: "FAIL", dcc: "FAIL"))
	}
}
