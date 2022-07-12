////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class AntigenTestProfileTests: CWATestCase {

	let jsonEncoder = JSONEncoder()
	let jsonDecoder = JSONDecoder()

	let mockId = UUID()

	func testGIVEN_RapidTestProfile_WHEN_SerializeToJson_THEN_FormateMatches() throws {
		// GIVEN
		let jsonFullString = """
		{"zipCode":"12345","city":"Musterstadt","firstName":"Max","id":"\(mockId)","phoneNumber":"+49150123456789","dateOfBirth":"1971-11-01","email":"max.mustermann@coronawarn.app","addressLine":"Musterstrasse 1a","lastName":"Mustermann"}
		"""
		let profile = AntigenTestProfile(
			id: mockId,
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
		let jsonFullString = """
		{"zipCode":"12345","city":"Musterstadt","firstName":"Max","id":"\(mockId)","phoneNumber":"+49150123456789","dateOfBirth":"1971-11-01","email":"max.mustermann@coronawarn.app","addressLine":"Musterstrasse 1a","lastName":"Mustermann"}
		"""
		let jsonData = try XCTUnwrap(jsonFullString.data(using: .utf8))

		// WHEN
		let rapidTestProfile = try XCTUnwrap(try? jsonDecoder.decode(AntigenTestProfile.self, from: jsonData))

		// THEN
		XCTAssertEqual(rapidTestProfile.id, mockId)
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
		let jsonDateOnlyString = """
		{"id":"\(mockId)","dateOfBirth":"1971-11-01"}
		"""
		let profile = AntigenTestProfile(
			id: mockId,
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
		let jsonDateOnlyString = """
		{"id":"\(mockId)","dateOfBirth":"1971-11-01"}
		"""
		let jsonData = try XCTUnwrap(jsonDateOnlyString.data(using: .utf8))

		// WHEN
		let rapidTestProfile = try XCTUnwrap(try? jsonDecoder.decode(AntigenTestProfile.self, from: jsonData))

		// THEN
		XCTAssertEqual(rapidTestProfile.dateOfBirth, Date(timeIntervalSince1970: 57801600))
	}


}
