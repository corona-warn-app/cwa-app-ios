////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class DigitalCovid19CertificateResourceTests: CWATestCase {

	func testGIVEN_UnexpectedServerError_202_WHEN_GettingCustomError_THEN_dccPending_ErrorIsReturned() throws {
		// GIVEN
		let resource = DigitalCovid19CertificateResource(
			isFake: true,
			sendModel: DigitalCovid19CertificateSendModel(
				registrationToken: ""
			)
		)

		// WHEN
		let customError = resource.customError(for: .unexpectedServerError(202))

		// THEN
		XCTAssertEqual(customError, .dccPending)
	}

	func testGIVEN_UnexpectedServerError_400_WHEN_GettingCustomError_THEN_badRequest_ErrorIsReturned() throws {
		// GIVEN
		let resource = DigitalCovid19CertificateResource(
			isFake: true,
			sendModel: DigitalCovid19CertificateSendModel(
				registrationToken: ""
			)
		)

		// WHEN
		let customError = resource.customError(for: .unexpectedServerError(400))

		// THEN
		XCTAssertEqual(customError, .badRequest)
	}

	func testGIVEN_UnexpectedServerError_404_WHEN_GettingCustomError_THEN_tokenDoesNotExist_ErrorIsReturned() throws {
		// GIVEN
		let resource = DigitalCovid19CertificateResource(
			isFake: true,
			sendModel: DigitalCovid19CertificateSendModel(
				registrationToken: ""
			)
		)

		// WHEN
		let customError = resource.customError(for: .unexpectedServerError(404))

		// THEN
		XCTAssertEqual(customError, .tokenDoesNotExist)
	}

	func testGIVEN_UnexpectedServerError_410_WHEN_GettingCustomError_THEN_dccAlreadyCleanedUp_ErrorIsReturned() throws {
		// GIVEN
		let resource = DigitalCovid19CertificateResource(
			isFake: true,
			sendModel: DigitalCovid19CertificateSendModel(
				registrationToken: ""
			)
		)

		// WHEN
		let customError = resource.customError(for: .unexpectedServerError(410))

		// THEN
		XCTAssertEqual(customError, .dccAlreadyCleanedUp)
	}

	func testGIVEN_UnexpectedServerError_412_WHEN_GettingCustomError_THEN_testResultNotYetReceived_ErrorIsReturned() throws {
		// GIVEN
		let resource = DigitalCovid19CertificateResource(
			isFake: true,
			sendModel: DigitalCovid19CertificateSendModel(
				registrationToken: ""
			)
		)

		// WHEN
		let customError = resource.customError(for: .unexpectedServerError(412))

		// THEN
		XCTAssertEqual(customError, .testResultNotYetReceived)
	}

	func testGIVEN_UnexpectedServerError_500_WithEmptyResponseBody_WHEN_GettingCustomError_THEN_unhandledResponse_ErrorIsReturned() throws {
		// GIVEN
		let resource = DigitalCovid19CertificateResource(
			isFake: true,
			sendModel: DigitalCovid19CertificateSendModel(
				registrationToken: ""
			)
		)

		// WHEN
		let customError = resource.customError(
			for: .unexpectedServerError(500),
			responseBody: nil
		)

		// THEN
		XCTAssertEqual(customError, .unhandledResponse(500))
	}

	func testGIVEN_UnexpectedServerError_500_WithInvalidResponseBody_WHEN_GettingCustomError_THEN_internalServerErrorWithoutReasonIsReturned() throws {
		// GIVEN
		let resource = DigitalCovid19CertificateResource(
			isFake: true,
			sendModel: DigitalCovid19CertificateSendModel(
				registrationToken: ""
			)
		)

		// WHEN
		let customError = resource.customError(
			for: .unexpectedServerError(500),
			responseBody: Data()
		)

		// THEN
		XCTAssertEqual(customError, .internalServerError(reason: nil))
	}

	func testGIVEN_UnexpectedServerError_500_WithValidResponseBody_WHEN_GettingCustomError_THEN_internalServerErrorWithoutReasonIsReturned() throws {
		// GIVEN
		let resource = DigitalCovid19CertificateResource(
			isFake: true,
			sendModel: DigitalCovid19CertificateSendModel(
				registrationToken: ""
			)
		)

		let dcc500Response = DCC500Response(reason: "reason for 500")
		let responseBody = try JSONEncoder().encode(dcc500Response)

		// WHEN
		let customError = resource.customError(
			for: .unexpectedServerError(500),
			responseBody: responseBody
		)

		// THEN
		XCTAssertEqual(customError, .internalServerError(reason: "reason for 500"))
	}

	func testGIVEN_UnexpectedServerError_999_WHEN_GettingCustomError_THEN_unhandledResponse_ErrorIsReturned() throws {
		// GIVEN
		let resource = DigitalCovid19CertificateResource(
			isFake: true,
			sendModel: DigitalCovid19CertificateSendModel(
				registrationToken: ""
			)
		)

		// WHEN
		let customError = resource.customError(for: .unexpectedServerError(999))

		// THEN
		XCTAssertEqual(customError, .unhandledResponse(999))
	}

	func testGIVEN_transportationError_WHEN_GettingCustomError_THEN_noNetworkConnection_ErrorIsReturned() throws {
		// GIVEN
		let resource = DigitalCovid19CertificateResource(
			isFake: true,
			sendModel: DigitalCovid19CertificateSendModel(
				registrationToken: ""
			)
		)

		// WHEN
		let customError = resource.customError(for: .transportationError(MockError.error("")))

		// THEN
		XCTAssertEqual(customError, .noNetworkConnection)
	}

	func testGIVEN_invalidResponse_WHEN_GettingCustomError_THEN_NilIsReturned() throws {
		// GIVEN
		let resource = DigitalCovid19CertificateResource(
			isFake: true,
			sendModel: DigitalCovid19CertificateSendModel(
				registrationToken: ""
			)
		)

		// WHEN
		let customError = resource.customError(for: .invalidResponse)

		// THEN
		XCTAssertNil(customError)
	}

}
