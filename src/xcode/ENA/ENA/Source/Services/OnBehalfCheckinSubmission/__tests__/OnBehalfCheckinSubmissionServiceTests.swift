//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class OnBehalfCheckinSubmissionServiceTests: CWATestCase {

	func testSuccessfulSubmission() {
		let client = ClientMock()

		let getRegistrationTokenExpectation = expectation(description: "getRegistrationTokenExpectation called")
		client.onGetRegistrationToken = { _, _, _, _, completion in
			completion(.success("registrationToken"))
			getRegistrationTokenExpectation.fulfill()
		}

		let getTANForExposureSubmitExpectation = expectation(description: "getTANForExposureSubmit called")
		client.onGetTANForExposureSubmit = { _, _, completion in
			completion(.success("submissionTAN"))
			getTANForExposureSubmitExpectation.fulfill()
		}

		let submitOnBehalfExpectation = expectation(description: "getRegistrationTokenExpectation called")
		client.onSubmitOnBehalf = { _, _, completion in
			completion(.success(()))
			submitOnBehalfExpectation.fulfill()
		}

		let service = OnBehalfCheckinSubmissionService(
			client: client,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			guard case .success = result else {
				XCTFail("Expected success")
				return
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

}
