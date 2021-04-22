////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class AntigenTestInformationTests: XCTestCase {

	func testGIVEN_AntigenTestInformationPayload_WHEN_Parse_THEN_WillBeEqual() throws {

		let dateString = "2010-08-01"
		let date = ISO8601DateFormatter.justDate.date(from: dateString)

		// GIVEN
		let antigenTestInformation = AntigenTestInformation(
			hash: "asbf3242",
			timestamp: 123456789,
			firstName: "Thomase",
			lastName: "Mustermann",
			dateOfBirth: date
		)
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .custom({ date, encoder in
			var container = encoder.singleValueContainer()
			try container.encode(ISO8601DateFormatter.justDate.string(from: date))
		})

		let payloadData = try encoder.encode(antigenTestInformation).base64EncodedData()
		let payload = try XCTUnwrap(String(data: payloadData, encoding: .utf8))

		// WHEN
		let checkTestInformation = try XCTUnwrap(AntigenTestInformation(payload: payload))

		// THEN
		XCTAssertEqual(checkTestInformation, antigenTestInformation)
		XCTAssertEqual(checkTestInformation.dateOfBirthString, "2010-08-01")
	}

}
