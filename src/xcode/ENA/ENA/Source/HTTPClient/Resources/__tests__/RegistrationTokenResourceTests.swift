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

}
