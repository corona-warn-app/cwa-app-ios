////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class DCCPublicKeyRegistrationResourceTests: CWATestCase {

	func testGIVEN_UnexpectedServerError_400_WHEN_GettingCustomError_THEN_badRequest_ErrorIsReturned() throws {
		// GIVEN
		let resource = DCCPublicKeyRegistrationResource(
			isFake: true,
			sendModel: DCCPublicKeyRegistrationSendModel(
				registrationToken: "",
				publicKey: ""
			)
		)

		// WHEN
		let customError = resource.customError(for: .unexpectedServerError(400))

		// THEN
		XCTAssertEqual(customError, .badRequest)
	}

	func testGIVEN_UnexpectedServerError_403_WHEN_GettingCustomError_THEN_tokenNotAllowed_ErrorIsReturned() throws {
		// GIVEN
		let resource = DCCPublicKeyRegistrationResource(
			isFake: true,
			sendModel: DCCPublicKeyRegistrationSendModel(
				registrationToken: "",
				publicKey: ""
			)
		)

		// WHEN
		let customError = resource.customError(for: .unexpectedServerError(403))

		// THEN
		XCTAssertEqual(customError, .tokenNotAllowed)
	}

	func testGIVEN_UnexpectedServerError_404_WHEN_GettingCustomError_THEN_tokenDoesNotExist_ErrorIsReturned() throws {
		// GIVEN
		let resource = DCCPublicKeyRegistrationResource(
			isFake: true,
			sendModel: DCCPublicKeyRegistrationSendModel(
				registrationToken: "",
				publicKey: ""
			)
		)

		// WHEN
		let customError = resource.customError(for: .unexpectedServerError(404))

		// THEN
		XCTAssertEqual(customError, .tokenDoesNotExist)
	}

	func testGIVEN_UnexpectedServerError_409_WHEN_GettingCustomError_THEN_tokenAlreadyAssigned_ErrorIsReturned() throws {
		// GIVEN
		let resource = DCCPublicKeyRegistrationResource(
			isFake: true,
			sendModel: DCCPublicKeyRegistrationSendModel(
				registrationToken: "",
				publicKey: ""
			)
		)

		// WHEN
		let customError = resource.customError(for: .unexpectedServerError(409))

		// THEN
		XCTAssertEqual(customError, .tokenAlreadyAssigned)
	}

	func testGIVEN_UnexpectedServerError_500_WHEN_GettingCustomError_THEN_internalServerError_ErrorIsReturned() throws {
		// GIVEN
		let resource = DCCPublicKeyRegistrationResource(
			isFake: true,
			sendModel: DCCPublicKeyRegistrationSendModel(
				registrationToken: "",
				publicKey: ""
			)
		)

		// WHEN
		let customError = resource.customError(for: .unexpectedServerError(500))

		// THEN
		XCTAssertEqual(customError, .internalServerError)
	}

	func testGIVEN_UnexpectedServerError_999_WHEN_GettingCustomError_THEN_unhandledResponse_ErrorIsReturned() throws {
		// GIVEN
		let resource = DCCPublicKeyRegistrationResource(
			isFake: true,
			sendModel: DCCPublicKeyRegistrationSendModel(
				registrationToken: "",
				publicKey: ""
			)
		)

		// WHEN
		let customError = resource.customError(for: .unexpectedServerError(999))

		// THEN
		XCTAssertEqual(customError, .unhandledResponse(999))
	}

	func testGIVEN_transportationError_WHEN_GettingCustomError_THEN_noNetworkConnection_ErrorIsReturned() throws {
		// GIVEN
		let resource = DCCPublicKeyRegistrationResource(
			isFake: true,
			sendModel: DCCPublicKeyRegistrationSendModel(
				registrationToken: "",
				publicKey: ""
			)
		)

		// WHEN
		let customError = resource.customError(for: .transportationError(MockError.error("")))

		// THEN
		XCTAssertEqual(customError, .noNetworkConnection)
	}

	func testGIVEN_invalidResponse_WHEN_GettingCustomError_THEN_NilIsReturned() throws {
		// GIVEN
		let resource = DCCPublicKeyRegistrationResource(
			isFake: true,
			sendModel: DCCPublicKeyRegistrationSendModel(
				registrationToken: "",
				publicKey: ""
			)
		)

		// WHEN
		let customError = resource.customError(for: .invalidResponse)

		// THEN
		XCTAssertNil(customError)
	}

}
