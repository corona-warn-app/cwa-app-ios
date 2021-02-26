//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class UIViewController_AlertTest: XCTestCase {


	func testAlertSimple() throws {
		let vc = UIViewController()
		let alert = vc.setupErrorAlert(message: "Error Message")

		XCTAssertEqual(alert.title, AppStrings.ExposureSubmission.generalErrorTitle)
		XCTAssertEqual(alert.message, "Error Message")
		XCTAssertFalse(alert.actions.isEmpty)
	}

	func testAlertSingleAction() throws {
		let vc = UIViewController()
		let alert = vc.setupErrorAlert(message: "Error Message")

		XCTAssertEqual(alert.title, AppStrings.ExposureSubmission.generalErrorTitle)
		XCTAssertEqual(alert.message, "Error Message")
		XCTAssertEqual(alert.actions.count, 1)
	}

	func testAlertDoubleAction() throws {
		let vc = UIViewController()
		let alert = vc.setupErrorAlert(
			message: "Error Message",
			secondaryActionTitle: "Retry Title"
		)

		XCTAssertEqual(alert.title, AppStrings.ExposureSubmission.generalErrorTitle)
		XCTAssertEqual(alert.message, "Error Message")
		XCTAssertEqual(alert.actions.count, 2)
		XCTAssertEqual(alert.actions[1].title, "Retry Title")
	}
}
