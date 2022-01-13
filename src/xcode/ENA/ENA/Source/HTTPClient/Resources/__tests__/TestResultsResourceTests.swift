//
// 🦠 Corona-Warn-App
//
@testable import ENA
import Foundation
import XCTest

final class TestResultsResourceTests: CWATestCase {

	func testGetTestResult_Success() throws {

		let expectation = expectation(description: "GetTestresult was a success")

		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try JSONEncoder().encode(
				TestResultModel.fake()
			)
		)
		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		let resource = TestResultResource(
			isFake: false,
			sendModel: RegistrationTokenSendModel(registrationToken: "12345")
		)

		serviceProvider.load(resource) { result in
			switch result {
			case .success:
				expectation.fulfill()
			case .failure:
				XCTFail("Failure is not an option")
			}
		}
		waitForExpectations(timeout: .short)
	}

	func testGetTestResult_ServerError() throws {
		let expectation = expectation(description: "GetTestresult was a failure")

		let stack = MockNetworkStack(
			httpStatus: 500,
			responseData: try JSONEncoder().encode(
				TestResultModel.fake()
			)
		)
		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		let resource = TestResultResource(
			isFake: false,
			sendModel: RegistrationTokenSendModel(registrationToken: "12345")
		)

		serviceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("success is not an option")
			case .failure(let error):
				guard case let .unexpectedServerError(httpCode) = error,
					  httpCode == 500 else {
						  XCTFail("unexpected error case")
						  return
					  }
				expectation.fulfill()
			}
		}
		waitForExpectations(timeout: .short)
	}

	func testGetTestResult_MalformedResponse() throws {
		let expectation = expectation(description: "GetTestresult was a failure")

		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data(bytes: [0xA, 0xB] as [UInt8], count: 2)
		)
		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		let resource = TestResultResource(
			isFake: false,
			sendModel: RegistrationTokenSendModel(registrationToken: "12345")
		)

		serviceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("success is not an option")
			case .failure(let error):
				// Successful test if we can extract the resourceError to an decoding error, regardless what JSON decoding error exactly it is.
				guard case let .resourceError(resourceError) = error,
					  case _ = ResourceError.decoding(resourceError) else {
						 
					XCTFail("unexpected error case")
					return
				}
				expectation.fulfill()
			}
		}
		waitForExpectations(timeout: .short)

	}

	func testGetTestResult_MalformedJSONResponse() throws {

		let expectation = expectation(description: "GetTestresult was a failure")

		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: """
			{ "notAValidKey":"1234" }
			""".data(using: .utf8)
		)
		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		let resource = TestResultResource(
			isFake: false,
			sendModel: RegistrationTokenSendModel(registrationToken: "12345")
		)

		serviceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("success is not an option")
			case .failure(let error):
				// Successful test if we can extract the resourceError to an decoding error, regardless what JSON decoding error exactly it is.
				guard case let .resourceError(resourceError) = error,
					  case _ = ResourceError.decoding(resourceError) else {
						 
					XCTFail("unexpected error case")
					return
				}
				expectation.fulfill()
			}
		}
		waitForExpectations(timeout: .short)
	}

	func testSubmit_VerifyPOSTBodyContent() throws {
		let expectedToken = "SomeToken"
		let sendPostExpectation = expectation(
			description: "Expect that the client sends a POST request"
		)
		let verifyPostBodyContent: MockUrlSession.URLRequestObserver = { request in
			defer { sendPostExpectation.fulfill() }

			guard let content = try? JSONDecoder().decode([String: String].self, from: request.httpBody ?? Data()) else {
				XCTFail("POST body was empty, expected registrationToken JSON!")
				return
			}

			guard content["registrationToken"] == expectedToken else {
				XCTFail("POST JSON body did not have registrationToken value, or it was incorrect!")
				return
			}
		}
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try JSONEncoder().encode(GetRegistrationTokenResponse(registrationToken: expectedToken)),
			requestObserver: verifyPostBodyContent
		)

		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		let resource = TestResultResource(
			isFake: false,
			sendModel: RegistrationTokenSendModel(registrationToken: expectedToken)
		)

		serviceProvider.load(resource) { _ in }

		waitForExpectations(timeout: .short)

	}
}
