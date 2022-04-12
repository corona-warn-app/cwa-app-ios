//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

// swiftlint:disable type_body_length
class OnBehalfCheckinSubmissionServiceTests: CWATestCase {

	func testSuccessfulSubmission() {
		let client = ClientMock()
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(TeleTanReceiveModel(registrationToken: "fake")),
				.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
			]
		)

		let submitOnBehalfExpectation = expectation(description: "getRegistrationTokenExpectation called")
		client.onSubmitOnBehalf = { _, _, completion in
			completion(.success(()))
			submitOnBehalfExpectation.fulfill()
		}

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
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

	func testSubmissionWithRegistrationTokenRequestErrorTeleTanAlreadyUsed() {
		let client = ClientMock()
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.failure(ServiceError<TeleTanError>.receivedResourceError(.teleTanAlreadyUsed))
			]
		)

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			client: client,
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
		let client = ClientMock()
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.failure(ServiceError<TeleTanError>.receivedResourceError(.qrAlreadyUsed))
			]
		)

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			client: client,
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
		let client = ClientMock()
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.failure(ServiceError<TeleTanError>.unexpectedServerError(400))
			]
		)

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			client: client,
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
		let client = ClientMock()
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.failure(ServiceError<TeleTanError>.unexpectedServerError(500))
			]
		)

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			client: client,
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
		let client = ClientMock()
		let errorFake = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.failure(ServiceError<TeleTanError>.transportationError(errorFake))
			]
		)

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			client: client,
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
		let client = ClientMock()
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(TeleTanReceiveModel(registrationToken: "fake")),
				.failure(ServiceError<RegistrationTokenError>.unexpectedServerError(400))
			]
		)

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			client: client,
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
		let client = ClientMock()
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(TeleTanReceiveModel(registrationToken: "fake")),
				.failure(ServiceError<RegistrationTokenError>.unexpectedServerError(500))
			]
		)

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			client: client,
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
		let client = ClientMock()
		let errorFake = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(TeleTanReceiveModel(registrationToken: "fake")),
				.failure(ServiceError<RegistrationTokenError>.transportationError(errorFake))
			]
		)

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			client: client,
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
		let client = ClientMock()
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(TeleTanReceiveModel(registrationToken: "fake")),
				.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
			]
		)

		let submitOnBehalfExpectation = expectation(description: "getRegistrationTokenExpectation called")
		client.onSubmitOnBehalf = { _, _, completion in
			completion(.failure(.invalidPayloadOrHeaders))
			submitOnBehalfExpectation.fulfill()
		}

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			client: client,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .submissionError(.invalidPayloadOrHeaders))
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
		let client = ClientMock()
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(TeleTanReceiveModel(registrationToken: "fake")),
				.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
			]
		)

		let submitOnBehalfExpectation = expectation(description: "getRegistrationTokenExpectation called")
		client.onSubmitOnBehalf = { _, _, completion in
			completion(.failure(.invalidTan))
			submitOnBehalfExpectation.fulfill()
		}

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			client: client,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .submissionError(.invalidTan))
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
		let client = ClientMock()
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(TeleTanReceiveModel(registrationToken: "fake")),
				.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
			]
		)

		let submitOnBehalfExpectation = expectation(description: "getRegistrationTokenExpectation called")
		client.onSubmitOnBehalf = { _, _, completion in
			completion(.failure(.other(.serverError(400))))
			submitOnBehalfExpectation.fulfill()
		}

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			client: client,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .submissionError(.other(.serverError(400))))
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
		let client = ClientMock()
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(TeleTanReceiveModel(registrationToken: "fake")),
				.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
			]
		)

		let submitOnBehalfExpectation = expectation(description: "getRegistrationTokenExpectation called")
		client.onSubmitOnBehalf = { _, _, completion in
			completion(.failure(.other(.serverError(500))))
			submitOnBehalfExpectation.fulfill()
		}

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			client: client,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .submissionError(.other(.serverError(500))))
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
		let client = ClientMock()
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(TeleTanReceiveModel(registrationToken: "fake")),
				.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
			]
		)

		let submitOnBehalfExpectation = expectation(description: "getRegistrationTokenExpectation called")
		client.onSubmitOnBehalf = { _, _, completion in
			completion(.failure(.other(.noNetworkConnection)))
			submitOnBehalfExpectation.fulfill()
		}

		let service = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			client: client,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .submissionError(.other(.noNetworkConnection)))
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
