//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ExposureSubmissionSymptomsViewControllerTests: XCTestCase {

	private func createVC() -> ExposureSubmissionSymptomsViewController {
		AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionSymptomsViewController.self) { coder -> UIViewController? in
			ExposureSubmissionSymptomsViewController(coder: coder, onPrimaryButtonTap: { _ in })
		}
	}

	func testCellsOnScreen() {
		let vc = createVC()
		_ = vc.view

		let section = vc.dynamicTableViewModel.section(0)
		let cells = section.cells
		XCTAssertEqual(cells.count, 10)

		let firstItem = cells[0]
		var id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")

		let secondItem = cells[1]
		id = secondItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "bulletPointCell")

		let thirdItem = cells[2]
		id = thirdItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "bulletPointCell")

		let fourthItem = cells[3]
		id = fourthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "bulletPointCell")
		
		let fifthItem = cells[4]
		id = fifthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "bulletPointCell")
		
		let sixthItem = cells[5]
		id = sixthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "bulletPointCell")

		let seventhItem = cells[6]
		id = seventhItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "bulletPointCell")

		let eighthItem = cells[7]
		id = eighthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "bulletPointCell")
		
		let ninthItem = cells[8]
		id = ninthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "bulletPointCell")
		
		let tenthItem = cells[9]
		id = tenthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "optionGroupCell")
		
	}

}
