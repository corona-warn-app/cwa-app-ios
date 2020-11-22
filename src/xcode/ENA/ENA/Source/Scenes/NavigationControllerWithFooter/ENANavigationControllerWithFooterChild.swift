//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

protocol ENANavigationControllerWithFooterChild: UIViewController {
	var footerView: ENANavigationFooterView? { get }

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton)
	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapSecondaryButton button: UIButton)
}

extension ENANavigationControllerWithFooterChild {
	var navigationControllerWithFooter: ENANavigationControllerWithFooter? { navigationController as? ENANavigationControllerWithFooter }
	var navigationFooterItem: ENANavigationFooterItem? { navigationItem as? ENANavigationFooterItem }

	var footerView: ENANavigationFooterView? { navigationControllerWithFooter?.footerView }

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) { }
	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapSecondaryButton button: UIButton) { }
}
