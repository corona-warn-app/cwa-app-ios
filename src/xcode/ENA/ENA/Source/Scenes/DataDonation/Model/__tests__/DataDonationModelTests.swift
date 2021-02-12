//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DataDonationModelTests: XCTestCase {

	func testGIVEN_ModelWithJson_WHEN_GetValues_THEN_ValuesAreEqualToDefault() throws {
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

	func testGIVEN_ModelWithInvalidJson_WHEN_GetValues_THEN_ValuesAreEqualToDefault() throws {
		// GIVEN
		let mockStore = MockTestStore()

		let fileURL = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: "testDataInvalid", withExtension: "json"))
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
		XCTAssertEqual(model.allRegions(by: "Schleswig-Holstein").count, 0)
	}

	func testGIVEN_Model_WHEN_GetValues_THEN_ValuesAreEqualToSore() throws {
		// GIVEN
		let mockStore = MockTestStore()
		mockStore.isPrivacyPreservingAnalyticsConsentGiven = true
		mockStore.userMetadata = UserMetadata(federalState: FederalStateName.schleswigHolstein, administrativeUnit: 11001053, ageGroup: .ageBelow29)

		let fileURL = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: "testData", withExtension: "json"))
		let model = DataDonationModel(store: mockStore, jsonFileURL: fileURL)

		// WHEN
		let consentGiven = model.isConsentGiven
		let federalStateName = model.federalStateName
		let region = model.region
		let age = model.age

		// THEN
		XCTAssertTrue(consentGiven)
		XCTAssertEqual(federalStateName, "Schleswig-Holstein")
		XCTAssertEqual(region, "Herzogtum Lauenburg")
		XCTAssertEqual(age, AgeGroup.ageBelow29.text)
	}

	func testGIVEN_Model_WHEN_InvalidateConsentAndSave_THEN_ValuesAreNil() throws {
		// GIVEN
		let mockStore = MockTestStore()
		mockStore.isPrivacyPreservingAnalyticsConsentGiven = true
		mockStore.userMetadata = UserMetadata(federalState: FederalStateName.schleswigHolstein, administrativeUnit: 11001053, ageGroup: .ageBelow29)

		let fileURL = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: "testData", withExtension: "json"))
		var model = DataDonationModel(store: mockStore, jsonFileURL: fileURL)

		// WHEN
		model.isConsentGiven = false
		model.save()

		let federalStateName = model.federalStateName
		let region = model.region
		let age = model.age

		// THEN
		XCTAssertFalse(mockStore.isPrivacyPreservingAnalyticsConsentGiven)
		XCTAssertNil(federalStateName)
		XCTAssertNil(region)
		XCTAssertNil(age)
	}

	func testGIVEN_Model_WHEN_Save_THEN_StoreValuesMatch() throws {
		// GIVEN
		let mockStore = MockTestStore()
		mockStore.isPrivacyPreservingAnalyticsConsentGiven = true
		mockStore.userMetadata = UserMetadata(federalState: FederalStateName.schleswigHolstein, administrativeUnit: 11001053, ageGroup: .ageBelow29)

		let fileURL = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: "testData", withExtension: "json"))
		var model = DataDonationModel(store: mockStore, jsonFileURL: fileURL)

		// WHEN
		model.save()

		// THEN
		let userMetaData = try XCTUnwrap(mockStore.userMetadata)
		XCTAssertEqual(userMetaData.ageGroup?.text, model.age)
		XCTAssertEqual(userMetaData.federalState?.rawValue, model.federalStateName)
		XCTAssertEqual(userMetaData.administrativeUnit, 11001053)

	}

}
