//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class DeltaOnboardingNavigationController: ENANavigationControllerWithFooter, UINavigationControllerDelegate, DeltaOnboardingViewControllerProtocol {

	// MARK: - Attributes.

	var finished: (() -> Void)?

}
