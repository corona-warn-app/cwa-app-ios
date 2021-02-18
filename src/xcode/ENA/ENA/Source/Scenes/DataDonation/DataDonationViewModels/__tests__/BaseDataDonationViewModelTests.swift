////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class BaseDataDonationViewModelTests: XCTestCase {

	/// test if the view model will format texts correct
	func testGIVEN_ViewModelWithStoredData_WHEN_getFriendlyTexts_THEN_ValuesAreEqualToStore() throws {
		// GIVEN
		let mockStore = MockTestStore()
		mockStore.isPrivacyPreservingAnalyticsConsentGiven = true
		mockStore.userMetadata = UserMetadata(federalState: FederalStateName.schleswigHolstein, administrativeUnit: 11001053, ageGroup: .ageBelow29)

		let fileURL = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: "testData", withExtension: "json"))
		let model = DataDonationModel(store: mockStore, jsonFileURL: fileURL)

		let viewModel = BaseDataDonationViewModel(store: mockStore, presentSelectValueList: { _ in }, datadonationModel: model)

		// WHEN
		let friendlyFederalStateName = viewModel.friendlyFederalStateName
		let friendlyRegionName = viewModel.friendlyRegionName
		let friendlyAgeName = viewModel.friendlyAgeName

		// THEN
		XCTAssertEqual(friendlyFederalStateName, FederalStateName.schleswigHolstein.rawValue)
		XCTAssertEqual(friendlyRegionName, "Herzogtum Lauenburg")
		XCTAssertEqual(friendlyAgeName, AgeGroup.ageBelow29.text)
	}

	/// test if the view model will format empty texts correct
	func testGIVEN_ViewModelWithoutStoredData_WHEN_getFriendlyTexts_THEN_ValuesAreEqualToStore() throws {
		// GIVEN
		let mockStore = MockTestStore()

		let fileURL = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: "testData", withExtension: "json"))
		let model = DataDonationModel(store: mockStore, jsonFileURL: fileURL)

		let viewModel = BaseDataDonationViewModel(store: mockStore, presentSelectValueList: { _ in }, datadonationModel: model)

		// WHEN
		let friendlyFederalStateName = viewModel.friendlyFederalStateName
		let friendlyRegionName = viewModel.friendlyRegionName
		let friendlyAgeName = viewModel.friendlyAgeName

		// THEN

		XCTAssertEqual(friendlyFederalStateName, AppStrings.DataDonation.Info.noSelectionState)
		XCTAssertEqual(friendlyRegionName, AppStrings.DataDonation.Info.noSelectionRegion)
		XCTAssertEqual(friendlyAgeName, AppStrings.DataDonation.Info.noSelectionAgeGroup)
	}

	// test if an empty store will update if the view model will save with consent given
	func testGIVEN_ViewModelWithEmptyStore_WHEN_SaveWithConset_THEN_StoreIsUpdatedWithValues() throws {
		// GIVEN
		let mockStore = MockTestStore()
		Analytics.setupMock(store: mockStore)

		let fileURL = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: "testData", withExtension: "json"))
		var model = DataDonationModel(store: mockStore, jsonFileURL: fileURL)
		model.region = "Offenbach (Landkreis)" // ID = 11006438
		model.federalStateName = "Hessen"
		model.age = AgeGroup.ageBelow29.text

		let viewModel = BaseDataDonationViewModel(store: mockStore, presentSelectValueList: { _ in }, datadonationModel: model)

		// WHEN
		viewModel.save(consentGiven: true)

		// THEN
		XCTAssertTrue(mockStore.isPrivacyPreservingAnalyticsConsentGiven)
		XCTAssertEqual(mockStore.userMetadata?.ageGroup, .ageBelow29)
		XCTAssertEqual(mockStore.userMetadata?.federalState, .hessen)
		XCTAssertEqual(mockStore.userMetadata?.administrativeUnit, 11006438)
	}

	// test if a non empty store will update if the view model will save with consent given
	func testGIVEN_ViewModelWithStoredValues_WHEN_SaveWithConset_THEN_StoreIsUpdatedWithValues() throws {
		// GIVEN
		let mockStore = MockTestStore()
		Analytics.setupMock(store: mockStore)
		mockStore.isPrivacyPreservingAnalyticsConsentGiven = true
		mockStore.userMetadata = UserMetadata(federalState: FederalStateName.schleswigHolstein, administrativeUnit: 11001053, ageGroup: .ageBetween30And59)

		let fileURL = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: "testData", withExtension: "json"))
		var model = DataDonationModel(store: mockStore, jsonFileURL: fileURL)
		model.region = "Offenbach (Landkreis)" // ID = 11006438
		model.federalStateName = "Hessen"
		model.age = AgeGroup.ageBelow29.text

		let viewModel = BaseDataDonationViewModel(store: mockStore, presentSelectValueList: { _ in }, datadonationModel: model)

		// WHEN
		viewModel.save(consentGiven: true)

		// THEN
		XCTAssertTrue(mockStore.isPrivacyPreservingAnalyticsConsentGiven)
		XCTAssertEqual(mockStore.userMetadata?.ageGroup, .ageBelow29)
		XCTAssertEqual(mockStore.userMetadata?.federalState, .hessen)
		XCTAssertEqual(mockStore.userMetadata?.administrativeUnit, 11006438)
	}

	// test if a non empty store will cleared if the view model will save with consent not given
	func testGIVEN_ViewModelWithStoredValues_WHEN_SaveWithoutConset_THEN_StoreIsUpdatedWithValues() throws {
		// GIVEN
		let mockStore = MockTestStore()
		Analytics.setupMock(store: mockStore)
		mockStore.isPrivacyPreservingAnalyticsConsentGiven = true
		mockStore.userMetadata = UserMetadata(federalState: FederalStateName.schleswigHolstein, administrativeUnit: 11001053, ageGroup: .ageBetween30And59)

		let fileURL = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: "testData", withExtension: "json"))
		var model = DataDonationModel(store: mockStore, jsonFileURL: fileURL)
		model.region = "Offenbach (Landkreis)" // ID = 11006438
		model.federalStateName = "Hessen"
		model.age = AgeGroup.ageBelow29.text

		let viewModel = BaseDataDonationViewModel(store: mockStore, presentSelectValueList: { _ in }, datadonationModel: model)

		// WHEN
		viewModel.save(consentGiven: false)

		// THEN
		XCTAssertFalse(mockStore.isPrivacyPreservingAnalyticsConsentGiven)
		XCTAssertNil(mockStore.userMetadata?.ageGroup)
		XCTAssertNil(mockStore.userMetadata?.federalState)
		XCTAssertNil(mockStore.userMetadata?.administrativeUnit)
	}

}
