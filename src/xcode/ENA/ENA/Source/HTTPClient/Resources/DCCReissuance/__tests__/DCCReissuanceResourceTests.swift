//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class DCCReissuanceResourceTests: CWATestCase {

	// MARK: - Success

	func testGIVEN_Resource_WHEN_Response_200_THEN_ModelIsReturned() throws {

	}

	// MARK: - Failures

	func testGIVEN_Resource_WHEN_PinMismatch_THEN_DCC_RI_PIN_MISMATCH() throws {

	}

	func testGIVEN_Resource_WHEN_Response_Body_Is_Malformed_THEN_DCC_RI_PARSE_ERR() throws {

	}

	func testGIVEN_Resource_WHEN_TransportationError_THEN_DCC_RI_NO_NETWORK() throws {

	}

	func testGIVEN_Resource_WHEN_Response_PinMismatch_THEN_DCC_RI_PIN_MISMATCH() throws {

	}

	func testGIVEN_Resource_WHEN_Response_400_THEN_DCC_RI_400() throws {

	}

	func testGIVEN_Resource_WHEN_Response_401_THEN_DCC_RI_401() throws {

	}

	func testGIVEN_Resource_WHEN_Response_403_THEN_DCC_RI_403() throws {

	}

	func testGIVEN_Resource_WHEN_Response_406_THEN_DCC_RI_406() throws {

	}

	func testGIVEN_Resource_WHEN_Response_500_THEN_DCC_RI_500() throws {

	}

	func testGIVEN_Resource_WHEN_Response_456_THEN_DCC_RI_CLIENT_ERR() throws {

	}

	func testGIVEN_Resource_WHEN_Response_505_THEN_DCC_RI_SERVER_ERR() throws {

	}
}
