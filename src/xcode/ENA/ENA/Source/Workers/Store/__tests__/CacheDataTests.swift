//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class CacheDataTests: XCTestCase {

	let oldDataModel = "{\"date\":664816559.64525902,\"data\":\"\",\"eTag\":\"1234\"}".data(using: .utf8)
	let newDataModel = "{\"clientDate\":664818129.64525902, \"date\":664816559.64525902,\"data\":\"\",\"eTag\":\"1234\"}".data(using: .utf8)

	func testGIVEN_OldSerializeData_WHEN_Parse_THEN_ModelGetsCreated() throws {
		// GIVEN
		let jsonData = try XCTUnwrap(oldDataModel)

		// WHEN
		let cacheDataModel = try JSONDecoder().decode(CacheData.self, from: jsonData)

		// THEN
		XCTAssertEqual(cacheDataModel.eTag, "1234")
		XCTAssertEqual(cacheDataModel.serverDate, Date(timeIntervalSinceReferenceDate: 664816559.64525902))
		XCTAssertEqual(cacheDataModel.serverDate, cacheDataModel.clientDate)
	}

	func testGIVEN_NewSerializeData_WHEN_Parse_THEN_ModelGetsCreated() throws {
		// GIVEN
		let jsonData = try XCTUnwrap(newDataModel)

		// WHEN
		let cacheDataModel = try JSONDecoder().decode(CacheData.self, from: jsonData)

		// THEN
		XCTAssertEqual(cacheDataModel.eTag, "1234")
		XCTAssertEqual(cacheDataModel.serverDate, Date(timeIntervalSinceReferenceDate: 664816559.64525902))
		XCTAssertEqual(cacheDataModel.clientDate, Date(timeIntervalSinceReferenceDate: 664818129.64525902))
		XCTAssertNotEqual(cacheDataModel.serverDate, cacheDataModel.clientDate)
	}

}
