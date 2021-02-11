////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DataDonationModelTests: XCTestCase {


	func testGIVEN_InitModel_WHEN_GetValues_THEN_ValuesAreEqualToDefault() throws {
		// GIVEN
		let mockStore = MockTestStore()

		let fileURL = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: "testData", withExtension: "json"))
		let model = DataDonationModel(store: mockStore, jsonFileURL: fileURL)

		// WHEN
		let consentGiven = model.isConsentGiven
		let federalStateName = model.federalStateName
		let region = model.region
		let age = model.age

		// THEN
		XCTAssertFalse(consentGiven)
		XCTAssertNil(federalStateName)
		XCTAssertNil(region)
		XCTAssertNil(age)

		XCTAssertEqual(model.allFederalStateNames.count, 16)
		XCTAssertEqual(model.allRegions(by: "Schleswig-Holstein").count, 2)
	}

}
