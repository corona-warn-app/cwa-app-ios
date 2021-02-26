////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class EUSettingsViewModelTests: XCTestCase {

	func testGIVEN_EUSettingsViewModel_WHEN_CountCountries_THEN_Match() {
		// GIVEN
		let emptyViewModel = EUSettingsViewModel()

		let someViewModel = EUSettingsViewModel(
			countries:
				[
					Country(countryCode: "DE"),
					Country(countryCode: "FR"),
					Country(countryCode: "CH")
				]
				.compactMap { $0 }
		)

		// WHEN
		let count = emptyViewModel.countries.count
		let someCount = someViewModel.countries.count

		// THEN
		XCTAssertEqual(count, 0)
		XCTAssertEqual(someCount, 3)
	}

	func testGIVEN_EUSettingsViewModel_WHEN_euSettingsModel_THEN_CellsAndSectionCountIsCorrect() {
		// GIVEN
		let someViewModel = EUSettingsViewModel(
			countries:
				[
					Country(countryCode: "DE"),
					Country(countryCode: "FR"),
					Country(countryCode: "CH")
				]
				.compactMap { $0 }
		)

		// WHEN
		let dynamicTableViewModel = someViewModel.euSettingsModel()

		// THEN
		XCTAssertEqual(dynamicTableViewModel.numberOfSection, 3)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 0), 9)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 1), 1)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 2), 3)
	}

	func testGIVEN_EUSettingsViewModelWithOutContries_WHEN_euSettingsModel_THEN_CellsAndSectionCountIsCorrect() {
		// GIVEN
		let emptyViewModel = EUSettingsViewModel()

		// WHEN
		let dynamicTableViewModel = emptyViewModel.euSettingsModel()

		// THEN
		XCTAssertEqual(dynamicTableViewModel.numberOfSection, 3)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 0), 9)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 1), 1)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 2), 3)
	}


}
