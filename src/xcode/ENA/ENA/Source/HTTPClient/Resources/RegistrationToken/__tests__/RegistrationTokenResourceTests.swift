//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class RegistrationTokenResourceTests: CWATestCase {

	func testGetTANForExposureSubmission_RegistrationTokenSuccess() throws {
		let fakeTan = "fakeTan"
		let expectation = expectation(description: "Expect that we got a completion")

		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try JSONEncoder().encode(
				RegistrationReceiveModel(submissionTAN: fakeTan)
			)
		)

		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		let registrationTokenResource = RegistrationTokenResource(
			isFake: false,
			sendModel: RegistrationTokenSendModel(token: "Fake")
		)

		serviceProvider.load(registrationTokenResource) { result in
			switch result {
			case .success(let model):
				XCTAssertEqual(model.submissionTAN, fakeTan)
			case .failure:
				XCTFail("Encountered Error when receiving TAN!")
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}

	func testGetTANForExposureSubmission_TokenDoesNotExist() throws {
		let expectation = expectation(description: "Expect that we got a completion")

		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: Data()
		)

		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		let registrationTokenResource = RegistrationTokenResource(
			isFake: false,
			sendModel: RegistrationTokenSendModel(token: "Fake")
		)
		
		serviceProvider.load(registrationTokenResource) { result in
			switch result {
			case .success:
				XCTFail("Registration Token already used - should not succeed")
			case .failure(let error):
				guard case let .receivedResourceError(customError) = error,
					  .regTokenNotExist == customError else {
						  XCTFail("unexpected error case")
						  return
					  }
			}
			expectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testGetTANForExposureSubmission_MalformedResponse() throws {
		let expectation = expectation(description: "Expect that we got a completion")

		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data(bytes: [0xA, 0xB] as [UInt8], count: 2)
		)

		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		let registrationTokenResource = RegistrationTokenResource(
			isFake: false,
			sendModel: RegistrationTokenSendModel(token: "Fake")
		)

		serviceProvider.load(registrationTokenResource) { result in
			switch result {
			case .success:
				XCTFail("Backend returned random bytes - the request should have failed!")
			case .failure(let error):
				// Successful test if we can extract the resourceError to an decoding error, regardless what JSON decoding error exactly it is.
				guard case let .resourceError(resourceError) = error,
					  case let .decoding(decodingError) = resourceError,
					  case let .JSON_DECODING(someError) = decodingError,
					  case _ = someError else {
						 
					XCTFail("unexpected error case")
					return
				}
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}

	func testGetTANForExposureSubmission_MalformedJSONResponse() throws {
		let expectation = expectation(description: "Expect that we got a completion")

		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: """
			{ "Wrongexample":"Hello" }
			""".data(using: .utf8)
		)

		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		let registrationTokenResource = RegistrationTokenResource(
			isFake: false,
			sendModel: RegistrationTokenSendModel(token: "Fake")
		)


		serviceProvider.load(registrationTokenResource) { result in
			switch result {
			case .success:
				XCTFail("Backend returned random bytes - the request should have failed!")
			case .failure(let error):
				// Successful test if we can extract the resourceError to an decoding error, regardless what JSON decoding error exactly it is.
				guard case let .resourceError(resourceError) = error,
					  case let .decoding(decodingError) = resourceError,
					  case let .JSON_DECODING(someError) = decodingError,
					  case _ = someError else {
						 
					XCTFail("unexpected error case")
					return
				}
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}

	func testGetTANForExposureSubmission_VerifyPOSTBodyContent() throws {
		let fakeToken = "fake"

		let sendPostExpectation = expectation(
			description: "Expect that the client sends a POST request"
		)
		let verifyPostBodyContent: MockUrlSession.URLRequestObserver = { request in
			defer { sendPostExpectation.fulfill() }

			guard let content = try? JSONDecoder().decode([String: String].self, from: request.httpBody ?? Data()) else {
				XCTFail("POST body was empty, expected key & key type as JSON!")
				return
			}

			guard content["registrationToken"] == fakeToken else {
				XCTFail("POST JSON body did not have tokenString value, or it was incorrect!")
				return
			}

		}
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try JSONEncoder().encode(
				RegistrationReceiveModel(submissionTAN: "fakeTan")
			),
			requestObserver: verifyPostBodyContent
		)

		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		let registrationTokenResource = RegistrationTokenResource(
			isFake: false,
			sendModel: RegistrationTokenSendModel(token: fakeToken)
		)
		serviceProvider.load(registrationTokenResource) { _ in }

		waitForExpectations(timeout: .short)
	}
}
