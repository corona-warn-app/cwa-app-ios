////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DefaultDataDonationViewModelTests: XCTestCase {

	func testGIVEN_DataDonationModel_WHEN_getDynamicTableViewModel_THEN_SectionsAndCellCountsMatch() throws {
		// GIVEN
		let mockStore = MockTestStore()
		mockStore.isPrivacyPreservingAnalyticsConsentGiven = true
		mockStore.userMetadata = UserMetadata(federalState: FederalStateName.schleswigHolstein, administrativeUnit: 11001053, ageGroup: .ageBelow29)

		let fileURL = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: "testData", withExtension: "json"))
		let model = DataDonationModel(store: mockStore, jsonFileURL: fileURL)

		let viewModel = DefaultDataDonationViewModel(store: mockStore, presentSelectValueList: { _ in }, datadonationModel: model)

		// WHEN
		let dynamicTableViewModel = viewModel.dynamicTableViewModel

		// THEN
		XCTAssertEqual(dynamicTableViewModel.numberOfSection, 4)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 0), 2)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 1), 5)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 2), 1)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 3), 2)
	}

	func testGIVEN_DataDonationModel_WHEN_TapSelectState_THEN_ClosureGetsCalled() throws {
		// GIVEN
		let mockStore = MockTestStore()
		mockStore.isPrivacyPreservingAnalyticsConsentGiven = true
		mockStore.userMetadata = UserMetadata(federalState: FederalStateName.schleswigHolstein, administrativeUnit: 11001053, ageGroup: .ageBelow29)

		let fileURL = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: "testData", withExtension: "json"))
		let model = DataDonationModel(store: mockStore, jsonFileURL: fileURL)
		let expectationPresentList = expectation(description: "Present value list hit")
		let viewModel = DefaultDataDonationViewModel(store: mockStore, presentSelectValueList: { _ in
			expectationPresentList.fulfill()
		}, datadonationModel: model)

		// WHEN
		viewModel.didTapSelectStateButton()

		// THEN
		wait(for: [expectationPresentList], timeout: .medium)
	}

	func testGIVEN_DataDonationModel_WHEN_TapSelectRegion_THEN_ClosureGetsCalled() throws {
		// GIVEN
		let mockStore = MockTestStore()
		mockStore.isPrivacyPreservingAnalyticsConsentGiven = true
		mockStore.userMetadata = UserMetadata(federalState: FederalStateName.schleswigHolstein, administrativeUnit: 11001053, ageGroup: .ageBelow29)

		let fileURL = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: "testData", withExtension: "json"))
		let model = DataDonationModel(store: mockStore, jsonFileURL: fileURL)
		let expectationPresentList = expectation(description: "Present value list hit")
		let viewModel = DefaultDataDonationViewModel(store: mockStore, presentSelectValueList: { _ in
			expectationPresentList.fulfill()
		}, datadonationModel: model)

		// WHEN
		viewModel.didTapSelectRegionButton()

		// THEN
		wait(for: [expectationPresentList], timeout: .medium)
	}

	func testGIVEN_DataDonationModel_WHEN_TapSelectAge_THEN_ClosureGetsCalled() throws {
		// GIVEN
		let mockStore = MockTestStore()
		mockStore.isPrivacyPreservingAnalyticsConsentGiven = true
		mockStore.userMetadata = UserMetadata(federalState: FederalStateName.schleswigHolstein, administrativeUnit: 11001053, ageGroup: .ageBelow29)

		let fileURL = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: "testData", withExtension: "json"))
		let model = DataDonationModel(store: mockStore, jsonFileURL: fileURL)
		let expectationPresentList = expectation(description: "Present value list hit")
		let viewModel = DefaultDataDonationViewModel(store: mockStore, presentSelectValueList: { _ in
			expectationPresentList.fulfill()
		}, datadonationModel: model)

		// WHEN
		viewModel.didTapAgeButton()

		// THEN
		wait(for: [expectationPresentList], timeout: .medium)
	}

}
