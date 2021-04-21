////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class AntigenTestProfileTests: XCTestCase {

	let jsonEncoder = JSONEncoder()
	let jsonDecoder = JSONDecoder()

	let jsonFullString = """
	{"zipCode":"12345","city":"Musterstadt","phoneNumber":"+49150123456789","dateOfBirth":"1971-11-01","forename":"Max","email":"max.mustermann@coronawarn.app","addressLine":"Musterstrasse 1a","lastName":"Mustermann"}
	"""

	let jsonDateOnlyString = """
	{"dateOfBirth":"1971-11-01"}
	"""

	func testGIVEN_RapidTestProfile_WHEN_SerializeToJson_THEN_FormateMatches() throws {
		// GIVEN
		let profile = AntigenTestProfile(
			firstName: "Max",
			lastName: "Mustermann",
			dateOfBirth: Date(timeIntervalSince1970: 57801600),
			addressLine: "Musterstrasse 1a",
			zipCode: "12345",
			city: "Musterstadt",
			phoneNumber: "+49150123456789",
			email: "max.mustermann@coronawarn.app"
		)

		// WHEN
		let jsonData = try XCTUnwrap(try? jsonEncoder.encode(profile))
		let jsonResultString = String(data: jsonData, encoding: .utf8)

		// THEN
		XCTAssertEqual(jsonFullString, jsonResultString)
	}

	func testGIVEN_JsonString_WHEN_DecodeRapidTestProfile_THEN_ValuesAreSet() throws {
		// GIVEN
		let jsonData = try XCTUnwrap(jsonFullString.data(using: .utf8))

		// WHEN
		let rapidTestProfile = try XCTUnwrap(try? jsonDecoder.decode(AntigenTestProfile.self, from: jsonData))

		// THEN
		XCTAssertEqual(rapidTestProfile.firstName, "Max")
		XCTAssertEqual(rapidTestProfile.lastName, "Mustermann")
		XCTAssertEqual(rapidTestProfile.dateOfBirth, Date(timeIntervalSince1970: 57801600))
		XCTAssertEqual(rapidTestProfile.addressLine, "Musterstrasse 1a")
		XCTAssertEqual(rapidTestProfile.zipCode, "12345")
		XCTAssertEqual(rapidTestProfile.city, "Musterstadt")
		XCTAssertEqual(rapidTestProfile.phoneNumber, "+49150123456789")
		XCTAssertEqual(rapidTestProfile.email, "max.mustermann@coronawarn.app")
	}

	func testGIVEN_RapidTestProfileDateOnly_WHEN_SerializeToJson_THEN_FormateMatches() throws {
		// GIVEN
		let profile = AntigenTestProfile(
			dateOfBirth: Date(timeIntervalSince1970: 57801600)
		)

		// WHEN
		let jsonData = try XCTUnwrap(try? jsonEncoder.encode(profile))
		let jsonResultString = String(data: jsonData, encoding: .utf8)

		// THEN
		XCTAssertEqual(jsonDateOnlyString, jsonResultString)
	}

	func testGIVEN_JsonString_WHEN_DecodeRapidTestProfileDateOnly_THEN_ValuesAreSet() throws {
		// GIVEN
		let jsonData = try XCTUnwrap(jsonDateOnlyString.data(using: .utf8))

		// WHEN
		let rapidTestProfile = try XCTUnwrap(try? jsonDecoder.decode(AntigenTestProfile.self, from: jsonData))

		// THEN
		XCTAssertEqual(rapidTestProfile.dateOfBirth, Date(timeIntervalSince1970: 57801600))
	}


}
