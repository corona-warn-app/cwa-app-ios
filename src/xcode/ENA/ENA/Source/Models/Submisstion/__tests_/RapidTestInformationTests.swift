////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class RapidTestInformationTests: CWATestCase {

	func testGIVEN_RapidTestInformationPayload_WHEN_Parse_THEN_WillBeEqual() throws {
		let dateString = "2010-08-01"
		let date = ISO8601DateFormatter.justUTCDateFormatter.date(from: dateString)

		// GIVEN
		let rapidTestInformation = RapidTestQRCodeInformation(
			hash: "asbf3242",
			timestamp: 123456789,
			firstName: "Thomase",
			lastName: "Mustermann",
			dateOfBirth: date,
			testID: "123",
			cryptographicSalt: "456",
			certificateSupportedByPointOfCare: false
		)
		let encoder = JSONEncoder()
		let payloadData = try encoder.encode(rapidTestInformation).base64EncodedData()
		let payload = try XCTUnwrap(String(data: payloadData, encoding: .utf8))

		// WHEN
		let checkTestInformation = try XCTUnwrap(RapidTestQRCodeInformation(payload: payload))

		// THEN
		XCTAssertEqual(checkTestInformation, rapidTestInformation)
		XCTAssertEqual(checkTestInformation.dateOfBirthString, "2010-08-01")
	}
}
