//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class CacheDataTests: XCTestCase {

	let oldDataModel = "{\"date\":664816559.64525902,\"data\":\"\",\"eTag\":\"1234\"}".data(using: .utf8)

	func testGIVEN_OldSerializeData_WHEN_Parse_THEN_ModelGetsCreated() throws {
		// GIVEN
		let jsonData = try XCTUnwrap(oldDataModel)

		// WHEN
		let cacheDataModel = try JSONDecoder().decode(CacheData.self, from: jsonData)

		// THEN
		XCTAssertEqual(cacheDataModel.eTag, "1234")
		XCTAssertEqual(cacheDataModel.date, Date(timeIntervalSinceReferenceDate: 664816559.64525902))
	}

}
