//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class ExposureSubmissionWarnOthersViewControllerTests: XCTestCase {

	override func setUp() {
		super.setUp()
	}

	private func createVC() -> ExposureSubmissionWarnOthersViewController {
		AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionWarnOthersViewController.self) { coder -> UIViewController? in
			ExposureSubmissionWarnOthersViewController(
				coder: coder,
				supportedCountries: ["DE", "IT", "ES", "NL", "CZ", "AT", "DK", "IE", "LV", "EE"].compactMap { Country(countryCode: $0) },
				onPrimaryButtonTap: { _ in }
			)
		}
	}

	func testCellsInSection0() {
		let vc = createVC()
		_ = vc.view

		let section = vc.dynamicTableViewModel.section(0)
		let cells = section.cells
		XCTAssertEqual(cells.count, 5)

		let firstItem = cells[0]
		var id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")

		let secondItem = cells[1]
		id = secondItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")

		let thirdItem = cells[2]
		id = thirdItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "spaceCell")

		let fourthItem = cells[3]
		id = fourthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")

  		let fifthItem = cells[4]
  		id = fifthItem.cellReuseIdentifier
  		XCTAssertEqual(id.rawValue, "spaceCell")
	}

	func testCellsInSection1() {
		let vc = createVC()
		_ = vc.view

		let section = vc.dynamicTableViewModel.section(1)
		let cells = section.cells
		XCTAssertEqual(cells.count, 10)

		let firstItem = cells[0]
		var id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "iconCell")

		let secondItem = cells[1]
		id = secondItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "iconCell")

		let thirdItem = cells[2]
		id = thirdItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "iconCell")

		let fourthItem = cells[3]
		id = fourthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "iconCell")

		let fifthItem = cells[4]
		id = fifthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "iconCell")

		let sixthItem = cells[5]
		id = sixthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "iconCell")

		let seventhItem = cells[6]
		id = seventhItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "iconCell")

		let eighthItem = cells[7]
		id = eighthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "iconCell")

		let ninthItem = cells[8]
		id = ninthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "iconCell")

		let tenthItem = cells[9]
		id = tenthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "iconCell")
	}

	func testCellsInSection2() {
		let vc = createVC()
		_ = vc.view

		let section = vc.dynamicTableViewModel.section(2)
		let cells = section.cells
		XCTAssertEqual(cells.count, 3)

		let firstItem = cells[0]
		var id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "spaceCell")

		let secondItem = cells[1]
		id = secondItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "roundedCell")

		let thirdItem = cells[2]
		id = thirdItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "roundedCell")
	}

}
