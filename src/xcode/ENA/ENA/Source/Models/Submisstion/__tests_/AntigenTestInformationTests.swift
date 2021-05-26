////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class AntigenTestInformationTests: XCTestCase {

	func testGIVEN_AntigenTestInformationPayload_WHEN_Parse_THEN_WillBeEqual() throws {

		let dateString = "2010-08-01"
		let date = AntigenTestInformation.isoFormatter.date(from: dateString)

		// GIVEN
		let antigenTestInformation = AntigenTestInformation(
			hash: "asbf3242",
			timestamp: 123456789,
			firstName: "Thomase",
			lastName: "Mustermann",
			dateOfBirth: date,
			testID: "123",
			cryptographicSalt: "456"
		)
		let encoder = JSONEncoder()
		let payloadData = try encoder.encode(antigenTestInformation).base64EncodedData()
		let payload = try XCTUnwrap(String(data: payloadData, encoding: .utf8))

		// WHEN
		let checkTestInformation = try XCTUnwrap(AntigenTestInformation(payload: payload))

		// THEN
		XCTAssertEqual(checkTestInformation, antigenTestInformation)
		XCTAssertEqual(checkTestInformation.dateOfBirthString, "2010-08-01")
	}

}
