//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
class TanInputViewControllerTests: XCTestCase {

	private var service: MockExposureSubmissionService!

	override func setUp() {
		super.setUp()
		service = MockExposureSubmissionService()
	}

	private func createVC() -> TanInputViewController {
		return TanInputViewController(coordinator: MockExposureSubmissionCoordinator(), exposureSubmissionService: self.service)
	}

	func testTanInputSuccess() {
		let vc = createVC()
		_ = vc.view

		let expectation = self.expectation(description: "Call getRegistration service method.")
		service.getRegistrationTokenCallback = { _, completion in
			expectation.fulfill()
			completion(.success(""))
		}

		vc.tanInput.insertText("234567893D")
		if vc.tanInput.isEnabled {
			_ = vc.enaTanInputDidTapReturn(vc.tanInput)
		}
		
		waitForExpectations(timeout: .short)
	}

	// Checks that a wrong TAN was input.
	func testWrongTan() {
		let vc = createVC()
		_ = vc.view

		vc.tanInput.insertText("ZBYKEVDBNU")
		XCTAssert(vc.errorView.alpha == 1)
		XCTAssert(vc.errorLabel.text == AppStrings.ExposureSubmissionTanEntry.invalidError)
	}

	// Checks that a TAN with one wrong character was input.
	func testWrongCharacterTan() {
		let vc = createVC()
		_ = vc.view

		vc.tanInput.insertText("ZBYKEVDBNL")
		XCTAssert(vc.errorView.alpha == 1)
		XCTAssert(vc.errorLabel.text == "\(AppStrings.ExposureSubmissionTanEntry.invalidError)\n\n\(AppStrings.ExposureSubmissionTanEntry.invalidCharacterError)")
	}

}
