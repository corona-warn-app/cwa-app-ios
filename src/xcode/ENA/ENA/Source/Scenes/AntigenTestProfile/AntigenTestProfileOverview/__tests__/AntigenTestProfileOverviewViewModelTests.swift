//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine

class AntigenTestProfileOverviewViewModelTests: CWATestCase {
	
	func testNumberOfSections() throws {
		let store = MockTestStore()
		
		let viewModel = AntigenTestProfileOverviewViewModel(
			store: store,
			onEntryCellTap: { _ in }
		)

		XCTAssertEqual(viewModel.numberOfSections, 2)
	}
	
	func testNumberOfRowsWithEmptyEntriesSection() throws {
		let store = MockTestStore()
		
		let viewModel = AntigenTestProfileOverviewViewModel(
			store: store,
			onEntryCellTap: { _ in }
		)

		XCTAssertEqual(viewModel.numberOfRows(in: AntigenTestProfileOverviewViewModel.Section.add.rawValue), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: AntigenTestProfileOverviewViewModel.Section.entries.rawValue), 0)
	}
	
	func testNumberOfRowsWithNonEmptyEntriesSection() throws {
		let store = MockTestStore()
		
		let antigenTestProfile = AntigenTestProfile(
			firstName: "Max",
			lastName: "Mustermann",
			dateOfBirth: Date(timeIntervalSince1970: 390047238),
			addressLine: "Blumenstraße 2",
			zipCode: "43923",
			city: "Berlin",
			phoneNumber: "0165434563",
			email: "sabine.schulz@gmx.com"
		)
		store.antigenTestProfiles = [antigenTestProfile]

		let viewModel = AntigenTestProfileOverviewViewModel(
			store: store,
			onEntryCellTap: { _ in }
		)

		XCTAssertEqual(viewModel.numberOfRows(in: AntigenTestProfileOverviewViewModel.Section.add.rawValue), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: AntigenTestProfileOverviewViewModel.Section.entries.rawValue), 1)
	}
	
	func testIsEmptyOnEmptyEntriesSection() throws {
		let store = MockTestStore()
		
		let viewModel = AntigenTestProfileOverviewViewModel(
			store: store,
			onEntryCellTap: { _ in }
		)
		
		XCTAssertTrue(viewModel.isEmpty)
	}
	
	func testIsEmptyOnNonEmptyEntriesSection() throws {
		let store = MockTestStore()
		
		let antigenTestProfile = AntigenTestProfile(
			firstName: "Max",
			lastName: "Mustermann",
			dateOfBirth: Date(timeIntervalSince1970: 390047238),
			addressLine: "Blumenstraße 2",
			zipCode: "43923",
			city: "Berlin",
			phoneNumber: "0165434563",
			email: "sabine.schulz@gmx.com"
		)
		store.antigenTestProfiles = [antigenTestProfile]

		let viewModel = AntigenTestProfileOverviewViewModel(
			store: store,
			onEntryCellTap: { _ in }
		)

		XCTAssertFalse(viewModel.isEmpty)
	}
	
	func testCellModels() throws {
		let store = MockTestStore()
		
		let antigenTestProfile1 = AntigenTestProfile(
			firstName: "Max",
			lastName: "Mustermann",
			dateOfBirth: Date(timeIntervalSince1970: 390047238),
			addressLine: "Blumenstraße 2",
			zipCode: "43923",
			city: "Berlin",
			phoneNumber: "0165434563",
			email: "sabine.schulz@gmx.com"
		)
		
		let antigenTestProfile2 = AntigenTestProfile(
			firstName: "Sabine",
			lastName: "Schulz",
			dateOfBirth: Date(timeIntervalSince1970: 390047238),
			addressLine: "Blumenstraße 2",
			zipCode: "43923",
			city: "Berlin",
			phoneNumber: "0165434563",
			email: "sabine.schulz@gmx.com"
		)
		
		store.antigenTestProfiles = [antigenTestProfile1, antigenTestProfile2]

		let viewModel = AntigenTestProfileOverviewViewModel(
			store: store,
			onEntryCellTap: { _ in }
		)

		XCTAssertEqual(
			viewModel.antigenTestPersonProfileCellModel(at: IndexPath(row: 0, section: AntigenTestProfileOverviewViewModel.Section.entries.rawValue)).name,
			"Max Mustermann"
		)
		XCTAssertEqual(
			viewModel.antigenTestPersonProfileCellModel(at: IndexPath(row: 1, section: AntigenTestProfileOverviewViewModel.Section.entries.rawValue)).name,
			"Sabine Schulz"
		)
	}
	
	func testDidTapEntryCell() throws {
		let store = MockTestStore()
		
		let antigenTestProfile = AntigenTestProfile(
			firstName: "Max",
			lastName: "Mustermann",
			dateOfBirth: Date(timeIntervalSince1970: 390047238),
			addressLine: "Blumenstraße 2",
			zipCode: "43923",
			city: "Berlin",
			phoneNumber: "0165434563",
			email: "sabine.schulz@gmx.com"
		)
		store.antigenTestProfiles = [antigenTestProfile]

		let cellTapExpectation = expectation(description: "onEntryCellTap called")

		let viewModel = AntigenTestProfileOverviewViewModel(
			store: store,
			onEntryCellTap: {
				XCTAssertEqual($0.firstName, "Max")
				XCTAssertEqual($0.lastName, "Mustermann")
				cellTapExpectation.fulfill()
			}
		)

		viewModel.didTapEntryCell(at: IndexPath(row: 0, section: AntigenTestProfileOverviewViewModel.Section.entries.rawValue))

		waitForExpectations(timeout: .medium)
	}
}
