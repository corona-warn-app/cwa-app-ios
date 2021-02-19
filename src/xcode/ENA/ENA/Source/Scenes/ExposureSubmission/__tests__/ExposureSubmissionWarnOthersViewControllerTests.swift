//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class ExposureSubmissionWarnOthersViewControllerTests: XCTestCase {
	
	private var store: Store!
	
	override func setUpWithError() throws {
		store = MockTestStore()
	}

	private func createVC() -> ExposureSubmissionWarnOthersViewController {
		ExposureSubmissionWarnOthersViewController(
			viewModel: ExposureSubmissionWarnOthersViewModel(
				supportedCountries: ["DE", "IT", "ES", "NL", "CZ", "AT", "DK", "IE", "LV", "EE"].compactMap { Country(countryCode: $0) },
				completion: nil),
			onPrimaryButtonTap: { _ in },
			dismiss: {}
		)
	}

	func testDynamicTableViewModel() {
		let viewModel = ExposureSubmissionWarnOthersViewModel(supportedCountries: [], completion: nil)

		let dynamicTableViewModel = viewModel.dynamicTableViewModel

		XCTAssertEqual(dynamicTableViewModel.numberOfSection, 4)
		XCTAssertEqual(dynamicTableViewModel.section(0).cells.count, 5)
		XCTAssertEqual(dynamicTableViewModel.section(1).cells.count, 2)
		XCTAssertEqual(dynamicTableViewModel.section(2).cells.count, 5)
		XCTAssertEqual(dynamicTableViewModel.section(3).cells.count, 2)
	}
}
