//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class UIViewController_AlertTest: XCTestCase {


	func testAlertSimple() throws {
		let vc = UIViewController()
		let alert = vc.setupErrorAlert(message: "Error Message")

		XCTAssert(alert.title == AppStrings.ExposureSubmission.generalErrorTitle)
		XCTAssert(alert.message == "Error Message")
		XCTAssert(!alert.actions.isEmpty)
	}

	func testAlertSingleAction() throws {
		let vc = UIViewController()
		let alert = vc.setupErrorAlert(message: "Error Message")

		XCTAssert(alert.title == AppStrings.ExposureSubmission.generalErrorTitle)
		XCTAssert(alert.message == "Error Message")
		XCTAssert(alert.actions.count == 1)
	}

	func testAlertDoubleAction() throws {
		let vc = UIViewController()
		let alert = vc.setupErrorAlert(
			message: "Error Message",
			secondaryActionTitle: "Retry Title"
		)

		XCTAssert(alert.title == AppStrings.ExposureSubmission.generalErrorTitle)
		XCTAssert(alert.message == "Error Message")
		XCTAssert(alert.actions.count == 2)
		XCTAssert(alert.actions[1].title == "Retry Title")
	}
}
