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
				SubmissionTANModel(submissionTAN: fakeTan)
			)
		)

		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		let registrationTokenResource = RegistrationTokenResource(
			isFake: false,
			sendModel: SendRegistrationTokenModel(token: "Fake")
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
			sendModel: SendRegistrationTokenModel(token: "Fake")
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
			sendModel: SendRegistrationTokenModel(token: "Fake")
		)

		serviceProvider.load(registrationTokenResource) { result in
			switch result {
			case .success:
				XCTFail("Backend returned random bytes - the request should have failed!")
			case .failure(let error):
				guard case let .resourceError(resourceError) = error,
					  resourceError == .decoding else {
					XCTFail("unexpected error case")
					return
				}
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}

}
