//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine

class DiaryOverviewViewModelTest: XCTestCase {

	func testDaysAreUpdatedWhenStoreChanges() throws {
		let diaryStore = makeMockStore()
		let store = MockTestStore()

		let viewModel = DiaryOverviewViewModel(
			diaryStore: diaryStore,
			store: store
		)

		let daysPublisherExpectation = expectation(description: "Days publisher called")
		daysPublisherExpectation.expectedFulfillmentCount = 2

		var subscriptions = [AnyCancellable]()
		viewModel.$days.sink { _ in
			daysPublisherExpectation.fulfill()
		}.store(in: &subscriptions)

		diaryStore.addContactPerson(name: "Martin Augst")

		waitForExpectations(timeout: .medium)
	}

	func testNumberOfSections() throws {
		let viewModel = DiaryOverviewViewModel(
			diaryStore: makeMockStore(),
			store: MockTestStore()
		)

		XCTAssertEqual(viewModel.numberOfSections, 2)
	}

	func testNumberOfRows() throws {
		let viewModel = DiaryOverviewViewModel(
			diaryStore: makeMockStore(),
			store: MockTestStore()
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 0), 1)

		XCTAssertEqual(viewModel.days.count, 15)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 15)
	}

	func testGIVEN_DiaryOverviewViewModel_WHEN_noneHistoryExposureIsInStore_THEN_NoneHistoryExposureIsReturned() {
		// GIVEN
		let viewModel = DiaryOverviewViewModel(
			diaryStore: makeMockStore(),
			store: MockTestStore()
		)

		// WHEN
		let diaryOverviewDayCellModel = viewModel.cellModel(for: IndexPath(row: 4, section: 0))

		// THEN
		XCTAssertEqual(diaryOverviewDayCellModel.historyExposure, .none)
	}

	func testGIVEN_DiaryOverviewViewModel_WHEN_lowHistoryExposureIsInStore_THEN_LowHistoryExposureIsReturned() throws {

		// GIVEN
		let dateFormatter = ISO8601DateFormatter.contactDiaryFormatter

		let todayString = dateFormatter.string(from: Date())
		let today = try XCTUnwrap(dateFormatter.date(from: todayString))

		let todayMinus5Days = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -5, to: today))
		let store = MockTestStore()
		store.riskCalculationResult = RiskCalculationResult(
			riskLevel: .low,
			minimumDistinctEncountersWithLowRisk: 1,
			minimumDistinctEncountersWithHighRisk: 1,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: nil,
			numberOfDaysWithLowRisk: 1,
			numberOfDaysWithHighRisk: 1,
			calculationDate: today,
			riskLevelPerDate: [todayMinus5Days: .low]
		)
		let viewModel = DiaryOverviewViewModel(
			diaryStore: makeMockStore(),
			store: store
		)

		// WHEN
		let diaryOverviewDayCellModel = viewModel.cellModel(for: IndexPath(row: 5, section: 0))

		// THEN
		XCTAssertEqual(diaryOverviewDayCellModel.historyExposure, .encounter(.low))
	}

	func testGIVEN_DiaryOverviewViewModel_WHEN_highHistoryExposureIsInStore_THEN_HighHistoryExposureIsReturned() throws {

		// GIVEN
		let dateFormatter = ISO8601DateFormatter.contactDiaryFormatter

		let todayString = dateFormatter.string(from: Date())
		let today = try XCTUnwrap(dateFormatter.date(from: todayString))

		let todayMinus5Days = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -7, to: today))
		let store = MockTestStore()
		store.riskCalculationResult = RiskCalculationResult(
			riskLevel: .low,
			minimumDistinctEncountersWithLowRisk: 1,
			minimumDistinctEncountersWithHighRisk: 1,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: nil,
			numberOfDaysWithLowRisk: 1,
			numberOfDaysWithHighRisk: 1,
			calculationDate: today,
			riskLevelPerDate: [todayMinus5Days: .high]
		)
		let viewModel = DiaryOverviewViewModel(
			diaryStore: makeMockStore(),
			store: store
		)


		// WHEN
		let diaryOverviewDayCellModel = viewModel.cellModel(for: IndexPath(row: 7, section: 0))
		let diaryOverviewDayCellModelNone = viewModel.cellModel(for: IndexPath(row: 5, section: 0))

		// THEN
		XCTAssertEqual(diaryOverviewDayCellModel.historyExposure, .encounter(.high))
		XCTAssertEqual(diaryOverviewDayCellModelNone.historyExposure, .none)

	}

	// MARK: - Private Helpers

	func makeMockStore() -> MockDiaryStore {
		let store = MockDiaryStore()
		store.addContactPerson(name: "Nick Gündling")
		store.addContactPerson(name: "Marcus Scherer")
		store.addContactPerson(name: "Artur Friesen")
		store.addContactPerson(name: "Pascal Brause")
		store.addContactPerson(name: "Kai Teuber")
		store.addContactPerson(name: "Karsten Gahn")
		store.addContactPerson(name: "Carsten Knoblich")
		store.addContactPerson(name: "Andreas Vogel")
		store.addContactPerson(name: "Puneet Mahali")
		store.addContactPerson(name: "Omar Ahmed")
		store.addLocation(name: "Supermarket")
		store.addLocation(name: "Bakery")

		return store
	}
	
}
