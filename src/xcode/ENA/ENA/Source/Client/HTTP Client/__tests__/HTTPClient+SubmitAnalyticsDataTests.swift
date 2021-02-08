////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class HTTPClientSubmitAnalyticsDataTests: XCTestCase {

	let expectationsTimeout: TimeInterval = 2

	func testGIVEN_SubmitAnalyticsData_WHEN_Success_THEN_CompletionIsEmpty() throws {

		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 204,
			responseData: Data()
		)

		let expectation = self.expectation(description: "completion handler is called without an error")
		let payload = SAP_Internal_Ppdd_PPADataIOS.with {
			$0.exposureRiskMetadataSet = []
		}
		let ppacToken = PPACToken(apiToken: "APITokenFake", deviceToken: "DeviceTokenFake")

		// WHEN
		var isSuccess = false
		HTTPClient.makeWith(mock: stack).submit(
			payload: payload,
			ppacToken: ppacToken,
			isFake: false,
			completion: { result in
				switch result {
			 case .success:
				isSuccess = true
				expectation.fulfill()
			 case .failure(let error):
				 XCTFail(error.localizedDescription)
			 }
			}
		)

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertTrue(isSuccess)
	}

	func testGIVEN_SubmitAnalyticsData_WHEN_FailureNoResponseData_THEN_CompletionHasFailureNoResponse() throws {

		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 401,
			responseData: nil
		)

		let expectation = self.expectation(description: "completion handler is called without an error")
		let payload = SAP_Internal_Ppdd_PPADataIOS.with {
			$0.exposureRiskMetadataSet = []
		}
		let ppacToken = PPACToken(apiToken: "APITokenFake", deviceToken: "DeviceTokenFake")

		// WHEN
		var expectedError: PPASError?
		HTTPClient.makeWith(mock: stack).submit(
			payload: payload,
			ppacToken: ppacToken,
			isFake: false,
			completion: { result in
				switch result {
			 case .success:
				XCTFail("This test should not success")
			 case .failure(let responseError):
				expectedError = responseError
				expectation.fulfill()
			 }
			}
		)

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertNotNil(expectedError)
		XCTAssertEqual(expectedError, .serverFailure(URLSession.Response.Failure.noResponse))
	}

	func testGIVEN_SubmitAnalyticsData_WHEN_FailureResponseNoJSON_THEN_CompletionHasFailureJsonError() throws {

		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: Data()
		)

		let expectation = self.expectation(description: "completion handler is called without an error")
		let payload = SAP_Internal_Ppdd_PPADataIOS.with {
			$0.exposureRiskMetadataSet = []
		}
		let ppacToken = PPACToken(apiToken: "APITokenFake", deviceToken: "DeviceTokenFake")

		// WHEN
		var expectedError: PPASError?
		HTTPClient.makeWith(mock: stack).submit(
			payload: payload,
			ppacToken: ppacToken,
			isFake: false,
			completion: { result in
				switch result {
			 case .success:
				XCTFail("This test should not success")
			 case .failure(let responseError):
				expectedError = responseError
				expectation.fulfill()
			 }
			}
		)

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertNotNil(expectedError)
		XCTAssertEqual(expectedError, .jsonError)
	}

	func testGIVEN_SubmitAnalyticsData_WHEN_FailureResponseInvalidJSON_THEN_CompletionHasFailureJsonError() throws {

		// GIVEN
		let response: [String: String] = ["WRONGJSONFORMAT": "API_TOKEN_EXPIRED"]
		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: try JSONEncoder().encode(response)
		)

		let expectation = self.expectation(description: "completion handler is called without an error")
		let payload = SAP_Internal_Ppdd_PPADataIOS.with {
			$0.exposureRiskMetadataSet = []
		}
		let ppacToken = PPACToken(apiToken: "APITokenFake", deviceToken: "DeviceTokenFake")

		// WHEN
		var expectedError: PPASError?
		HTTPClient.makeWith(mock: stack).submit(
			payload: payload,
			ppacToken: ppacToken,
			isFake: false,
			completion: { result in
				switch result {
			 case .success:
				XCTFail("This test should not success")
			 case .failure(let responseError):
				expectedError = responseError
				expectation.fulfill()
			 }
			}
		)

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertNotNil(expectedError)
		XCTAssertEqual(expectedError, .jsonError)
	}

	func testGIVEN_SubmitAnalyticsData_WHEN_FailureResponse400_THEN_CompletionHasFailureServerError400() throws {

		// GIVEN
		let response: [String: String] = ["errorState": "API_TOKEN_EXPIRED"]
		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: try JSONEncoder().encode(response)
		)

		let expectation = self.expectation(description: "completion handler is called without an error")
		let payload = SAP_Internal_Ppdd_PPADataIOS.with {
			$0.exposureRiskMetadataSet = []
		}
		let ppacToken = PPACToken(apiToken: "APITokenFake", deviceToken: "DeviceTokenFake")

		// WHEN
		var expectedError: PPASError?
		HTTPClient.makeWith(mock: stack).submit(
			payload: payload,
			ppacToken: ppacToken,
			isFake: false,
			completion: { result in
				switch result {
			 case .success:
				XCTFail("This test should not success")
			 case .failure(let responseError):
				expectedError = responseError
				expectation.fulfill()
			 }
			}
		)

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertNotNil(expectedError)
		XCTAssertEqual(expectedError, .serverError(.API_TOKEN_EXPIRED))
	}

	func testGIVEN_SubmitAnalyticsData_WHEN_FailureResponse500_THEN_CompletionHasFailureResponseError500() throws {

		// GIVEN
		let response: [String: String] = ["errorState": "API_TOKEN_EXPIRED"]
		let stack = MockNetworkStack(
			httpStatus: 500,
			responseData: try JSONEncoder().encode(response)
		)

		let expectation = self.expectation(description: "completion handler is called without an error")
		let payload = SAP_Internal_Ppdd_PPADataIOS.with {
			$0.exposureRiskMetadataSet = []
		}
		let ppacToken = PPACToken(apiToken: "APITokenFake", deviceToken: "DeviceTokenFake")

		// WHEN
		var expectedError: PPASError?
		HTTPClient.makeWith(mock: stack).submit(
			payload: payload,
			ppacToken: ppacToken,
			isFake: false,
			completion: { result in
				switch result {
			 case .success:
				XCTFail("This test should not success")
			 case .failure(let responseError):
				expectedError = responseError
				expectation.fulfill()
			 }
			}
		)

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertNotNil(expectedError)
		XCTAssertEqual(expectedError, .responseError(500))
	}

	func testGIVEN_SubmitAnalyticsData_WHEN_FailureResponse999_THEN_CompletionHasFailureResponseError999() throws {

		// GIVEN
		let response: [String: String] = ["errorState": "API_TOKEN_EXPIRED"]
		let stack = MockNetworkStack(
			httpStatus: 999,
			responseData: try JSONEncoder().encode(response)
		)

		let expectation = self.expectation(description: "completion handler is called without an error")
		let payload = SAP_Internal_Ppdd_PPADataIOS.with {
			$0.exposureRiskMetadataSet = []
		}
		let ppacToken = PPACToken(apiToken: "APITokenFake", deviceToken: "DeviceTokenFake")

		// WHEN
		var expectedError: PPASError?
		HTTPClient.makeWith(mock: stack).submit(
			payload: payload,
			ppacToken: ppacToken,
			isFake: false,
			completion: { result in
				switch result {
			 case .success:
				XCTFail("This test should not success")
			 case .failure(let responseError):
				expectedError = responseError
				expectation.fulfill()
			 }
			}
		)

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertNotNil(expectedError)
		XCTAssertEqual(expectedError, .responseError(999))
	}
}
