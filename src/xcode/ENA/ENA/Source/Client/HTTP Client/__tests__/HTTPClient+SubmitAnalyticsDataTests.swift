////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class HTTPClientSubmitAnalyticsDataTests: CWATestCase {

	let expectationsTimeout: TimeInterval = 2

	func testGIVEN_SubmitAnalyticsData_WHEN_Success_THEN_CompletionIsEmpty() throws {

		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 204,
			responseData: Data()
		)
		
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())

		let expectation = self.expectation(description: "completion handler is called without an error")
		let payload = SAP_Internal_Ppdd_PPADataIOS.with {
			$0.exposureRiskMetadataSet = []
		}
		let ppacToken = PPACToken(apiToken: "APITokenFake", previousApiToken: "PreviousAPITokenFake", deviceToken: "DeviceTokenFake")

		// WHEN
		var isSuccess = false
		
		let ppaSubmitResource = PPASubmitResource(
			forceApiTokenHeader: false,
			payload: payload,
			ppacToken: ppacToken
		)
		restService.load(ppaSubmitResource) { result in
			switch result {
			case .success:
				isSuccess = true
				expectation.fulfill()
			case .failure(let error):
				XCTFail(error.localizedDescription)
			}
		}
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
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())

		let expectation = self.expectation(description: "completion handler is called without an error")
		let payload = SAP_Internal_Ppdd_PPADataIOS.with {
			$0.exposureRiskMetadataSet = []
		}
		let ppacToken = PPACToken(apiToken: "APITokenFake", previousApiToken: "PreviousAPITokenFake", deviceToken: "DeviceTokenFake")
		
		let ppaSubmitResource = PPASubmitResource(
			forceApiTokenHeader: false,
			payload: payload,
			ppacToken: ppacToken
		)

		// WHEN
		restService.load(ppaSubmitResource) { result in
			switch result {
			case .success:
				XCTFail("This test should not success")
			case .failure(let responseError):
				XCTAssertNotNil(responseError)
				XCTAssertEqual(responseError, ServiceError<PPASubmitResourceError>.receivedResourceError(.responseError(401)))
				expectation.fulfill()
			}
		}

		// THEN
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_SubmitAnalyticsData_WHEN_FailureResponseNoJSON_THEN_CompletionHasFailureJsonError() throws {

		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: Data()
		)
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())

		let expectation = self.expectation(description: "completion handler is called without an error")
		let payload = SAP_Internal_Ppdd_PPADataIOS.with {
			$0.exposureRiskMetadataSet = []
		}
		let ppacToken = PPACToken(apiToken: "APITokenFake", previousApiToken: "PreviousAPITokenFake", deviceToken: "DeviceTokenFake")
		
		let ppaSubmitResource = PPASubmitResource(
			forceApiTokenHeader: false,
			payload: payload,
			ppacToken: ppacToken
		)

		// WHEN
		restService.load(ppaSubmitResource) { result in
			switch result {
			case .success:
				XCTFail("This test should not success")
			case .failure(let responseError):
				guard case let .receivedResourceError(customError) = responseError,
					  .jsonError == customError else {
						  XCTFail("Unexpected error case instead of expected .jsonError.")
						  return
					  }
				expectation.fulfill()
			}
		}

		// THEN
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_SubmitAnalyticsData_WHEN_FailureResponseInvalidJSON_THEN_CompletionHasFailureJsonError() throws {

		// GIVEN
		let response: [String: String] = ["WRONGJSONFORMAT": "API_TOKEN_EXPIRED"]
		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: try JSONEncoder().encode(response)
		)
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())

		let expectation = self.expectation(description: "completion handler is called without an error")
		let payload = SAP_Internal_Ppdd_PPADataIOS.with {
			$0.exposureRiskMetadataSet = []
		}
		let ppacToken = PPACToken(apiToken: "APITokenFake", previousApiToken: "PreviousAPITokenFake", deviceToken: "DeviceTokenFake")
		let ppaSubmitResource = PPASubmitResource(
			forceApiTokenHeader: false,
			payload: payload,
			ppacToken: ppacToken
		)

		// WHEN
		restService.load(ppaSubmitResource) { result in
			switch result {
			case .success:
			   XCTFail("This test should not success")
			case .failure(let responseError):
				guard case let .receivedResourceError(customError) = responseError,
					  .jsonError == customError else {
						  XCTFail("unexpected error case")
						  return
					  }
			   expectation.fulfill()
			}
		}

		// THEN
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_SubmitAnalyticsData_WHEN_FailureResponse400_THEN_CompletionHasFailureServerError400() throws {

		// GIVEN
		let response: [String: String] = ["errorCode": "API_TOKEN_EXPIRED"]
		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: try JSONEncoder().encode(response)
		)
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())

		let expectation = self.expectation(description: "completion handler is called without an error")
		let payload = SAP_Internal_Ppdd_PPADataIOS.with {
			$0.exposureRiskMetadataSet = []
		}
		let ppacToken = PPACToken(apiToken: "APITokenFake", previousApiToken: "PreviousAPITokenFake", deviceToken: "DeviceTokenFake")
		let ppaSubmitResource = PPASubmitResource(
			forceApiTokenHeader: false,
			payload: payload,
			ppacToken: ppacToken
		)

		// WHEN
		restService.load(ppaSubmitResource) { result in
			switch result {
			case .success:
			   XCTFail("This test should not success")
			case .failure(let responseError):
				guard case let .receivedResourceError(customError) = responseError,
					  .serverError(.API_TOKEN_EXPIRED) == customError else {
						  XCTFail("unexpected error case")
						  return
					  }
			   expectation.fulfill()
			}
		}

		// THEN
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_SubmitAnalyticsData_WHEN_FailureResponse500_THEN_CompletionHasFailureResponseError500() throws {

		// GIVEN
		let response: [String: String] = ["errorCode": "API_TOKEN_EXPIRED"]
		let stack = MockNetworkStack(
			httpStatus: 500,
			responseData: try JSONEncoder().encode(response)
		)
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())

		let expectation = self.expectation(description: "completion handler is called without an error")
		let payload = SAP_Internal_Ppdd_PPADataIOS.with {
			$0.exposureRiskMetadataSet = []
		}
		let ppacToken = PPACToken(apiToken: "APITokenFake", previousApiToken: "PreviousAPITokenFake", deviceToken: "DeviceTokenFake")
		let ppaSubmitResource = PPASubmitResource(
			forceApiTokenHeader: false,
			payload: payload,
			ppacToken: ppacToken
		)

		// WHEN
		restService.load(ppaSubmitResource) { result in
			switch result {
			case .success:
			   XCTFail("This test should not success")
			case .failure(let responseError):
				guard case let .receivedResourceError(customError) = responseError,
					  .responseError(500) == customError else {
						  XCTFail("unexpected error case")
						  return
					  }
			   expectation.fulfill()
			}
		}

		// THEN
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_SubmitAnalyticsData_WHEN_FailureResponse999_THEN_CompletionHasFailureResponseError999() throws {

		// GIVEN
		let response: [String: String] = ["errorCode": "API_TOKEN_EXPIRED"]
		let stack = MockNetworkStack(
			httpStatus: 999,
			responseData: try JSONEncoder().encode(response)
		)
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())

		let expectation = self.expectation(description: "completion handler is called without an error")
		let payload = SAP_Internal_Ppdd_PPADataIOS.with {
			$0.exposureRiskMetadataSet = []
		}
		let ppacToken = PPACToken(apiToken: "APITokenFake", previousApiToken: "PreviousAPITokenFake", deviceToken: "DeviceTokenFake")
		let ppaSubmitResource = PPASubmitResource(
			forceApiTokenHeader: false,
			payload: payload,
			ppacToken: ppacToken
		)

		// WHEN
		restService.load(ppaSubmitResource) { result in
			switch result {
			case .success:
			   XCTFail("This test should not success")
			case .failure(let responseError):
				guard case let .receivedResourceError(customError) = responseError,
					  .responseError(999) == customError else {
						  XCTFail("unexpected error case")
						  return
					  }
			   expectation.fulfill()
			}
		}

		// THEN
		waitForExpectations(timeout: .short)
	}
}
