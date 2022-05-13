//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class OnBehalfCheckinSubmissionServiceTests: CWATestCase {

	func testSuccessfulSubmission() {
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(TeleTanReceiveModel(registrationToken: "fake")),
				.success(RegistrationTokenReceiveModel(submissionTAN: "fake")),
				// OnBehalfSubmission response.
				.success(())
			]
		)

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
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

	func testSubmissionWithRegistrationTokenRequestErrorTeleTanAlreadyUsed() {
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.failure(ServiceError<TeleTanError>.receivedResourceError(.teleTanAlreadyUsed))
			]
		)

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .teleTanError(ServiceError<TeleTanError>.receivedResourceError(.teleTanAlreadyUsed)))
				XCTAssertEqual(
					error.localizedDescription,
					"Ungültige TAN. Bitte überprüfen Sie Ihre Eingabe oder kontaktieren Sie die Stelle, die Ihnen die TAN mitgeteilt hat. (REGTOKEN_OB_CLIENT_ERROR)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmissionWithRegistrationTokenRequestErrorQRAlreadyUsed() {
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.failure(ServiceError<TeleTanError>.receivedResourceError(.qrAlreadyUsed))
			]
		)

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .teleTanError(ServiceError<TeleTanError>.receivedResourceError(.qrAlreadyUsed)))
				XCTAssertEqual(
					error.localizedDescription,
					"Ungültige TAN. Bitte überprüfen Sie Ihre Eingabe oder kontaktieren Sie die Stelle, die Ihnen die TAN mitgeteilt hat. (REGTOKEN_OB_CLIENT_ERROR)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmissionWithRegistrationTokenRequestError40x() {
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.failure(ServiceError<TeleTanError>.unexpectedServerError(400))
			]
		)

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .teleTanError(.unexpectedServerError(400)))
				XCTAssertEqual(
					error.localizedDescription,
					"Ungültige TAN. Bitte überprüfen Sie Ihre Eingabe oder kontaktieren Sie die Stelle, die Ihnen die TAN mitgeteilt hat. (REGTOKEN_OB_CLIENT_ERROR)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmissionWithRegistrationTokenRequestError50x() {
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.failure(ServiceError<TeleTanError>.unexpectedServerError(500))
			]
		)

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .teleTanError(.unexpectedServerError(500)))
				XCTAssertEqual(
					error.localizedDescription,
					"Ein Fehler ist aufgetreten. Bitte versuchen Sie es später noch einmal oder kontaktieren Sie die technische Hotline über App-Informationen -> Technische Hotline. (REGTOKEN_OB_SERVER_ERROR)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmissionWithRegistrationTokenRequestNoNetworkError() {
		let errorFake = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.failure(ServiceError<TeleTanError>.transportationError(errorFake))
			]
		)

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .teleTanError(.transportationError(errorFake)))
				XCTAssertEqual(
					error.localizedDescription,
					"Ihre Internetverbindung wurde unterbrochen. Bitte prüfen Sie die Verbindung und versuchen Sie es erneut. (REGTOKEN_OB_NO_NETWORK)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmissionWithSubmissionTANRequestError40x() {
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(TeleTanReceiveModel(registrationToken: "fake")),
				.failure(ServiceError<RegistrationTokenError>.unexpectedServerError(400))
			]
		)

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .registrationTokenError(.unexpectedServerError(400)))
				XCTAssertEqual(
					error.localizedDescription,
					"Ein Fehler ist aufgetreten. Bitte kontaktieren Sie die technische Hotline über App-Informationen -> Technische Hotline. (TAN_OB_CLIENT_ERROR)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmissionWithSubmissionTANRequestError50x() {
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(TeleTanReceiveModel(registrationToken: "fake")),
				.failure(ServiceError<RegistrationTokenError>.unexpectedServerError(500))
			]
		)

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .registrationTokenError(.unexpectedServerError(500)))
				XCTAssertEqual(
					error.localizedDescription,
					"Ein Fehler ist aufgetreten. Bitte versuchen Sie es später noch einmal oder kontaktieren Sie die technische Hotline über App-Informationen -> Technische Hotline. (TAN_OB_SERVER_ERROR)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmissionWithSubmissionTANRequestNoNetworkError() {
		let errorFake = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(TeleTanReceiveModel(registrationToken: "fake")),
				.failure(ServiceError<RegistrationTokenError>.transportationError(errorFake))
			]
		)

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .registrationTokenError(.transportationError(errorFake)))
				XCTAssertEqual(
					error.localizedDescription,
					"Ihre Internetverbindung wurde unterbrochen. Bitte prüfen Sie die Verbindung und versuchen Sie es erneut. (TAN_OB_NO_NETWORK)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmissionWithSubmissionRequestInvalidPayloadOrHeadersError() {
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(TeleTanReceiveModel(registrationToken: "fake")),
				.success(RegistrationTokenReceiveModel(submissionTAN: "fake")),
				.failure(ServiceError<OnBehalfSubmissionResourceError>.receivedResourceError(.invalidPayloadOrHeaders))
			]
		)

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .submissionError(.receivedResourceError(.invalidPayloadOrHeaders)))
				XCTAssertEqual(
					error.localizedDescription,
					"Ein Fehler ist aufgetreten. Bitte kontaktieren Sie die technische Hotline über App-Informationen -> Technische Hotline. (SUBMISSION_OB_CLIENT_ERROR)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmissionWithSubmissionRequestInvalidTanError() {
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(TeleTanReceiveModel(registrationToken: "fake")),
				.success(RegistrationTokenReceiveModel(submissionTAN: "fake")),
				.failure(ServiceError<OnBehalfSubmissionResourceError>.receivedResourceError(.invalidTan))
			]
		)

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .submissionError(.receivedResourceError(.invalidTan)))
				XCTAssertEqual(
					error.localizedDescription,
					"Ein Fehler ist aufgetreten. Bitte kontaktieren Sie die technische Hotline über App-Informationen -> Technische Hotline. (SUBMISSION_OB_CLIENT_ERROR)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmissionWithSubmissionRequestError40x() {
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(TeleTanReceiveModel(registrationToken: "fake")),
				.success(RegistrationTokenReceiveModel(submissionTAN: "fake")),
				.failure(ServiceError<OnBehalfSubmissionResourceError>.receivedResourceError(.serverError(400)))
			]
		)

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .submissionError(.receivedResourceError(.serverError(400))))
				XCTAssertEqual(
					error.localizedDescription,
					"Ein Fehler ist aufgetreten. Bitte kontaktieren Sie die technische Hotline über App-Informationen -> Technische Hotline. (SUBMISSION_OB_CLIENT_ERROR)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmissionWithSubmissionRequestError50x() {
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(TeleTanReceiveModel(registrationToken: "fake")),
				.success(RegistrationTokenReceiveModel(submissionTAN: "fake")),
				.failure(ServiceError<OnBehalfSubmissionResourceError>.receivedResourceError(.serverError(500)))

			]
		)

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .submissionError(.receivedResourceError(.serverError(500))))
				XCTAssertEqual(
					error.localizedDescription,
					"Ein Fehler ist aufgetreten. Bitte versuchen Sie es später noch einmal oder kontaktieren Sie die technische Hotline über App-Informationen -> Technische Hotline. (SUBMISSION_OB_SERVER_ERROR)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmissionWithSubmissionRequestNoNetworkError() {
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(TeleTanReceiveModel(registrationToken: "fake")),
				.success(RegistrationTokenReceiveModel(submissionTAN: "fake")),
				.failure(ServiceError<OnBehalfSubmissionResourceError>.transportationError(FakeError.fake))
			]
		)

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(
					error.localizedDescription,
					"Ihre Internetverbindung wurde unterbrochen. Bitte prüfen Sie die Verbindung und versuchen Sie es erneut. (SUBMISSION_OB_NO_NETWORK)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

}
