//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
@testable import ENA

class MockExposureSubmissionNavigationControllerChild: UIViewController {
	var didTapButtonCallback: (() -> Void)?
	var didTapSecondButtonCallback: (() -> Void)?
}

extension MockExposureSubmissionNavigationControllerChild: ENANavigationControllerWithFooterChild {
	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		didTapButtonCallback?()
	}

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapSecondaryButton button: UIButton) {
		didTapSecondButtonCallback?()
	}
}
