////
// 🦠 Corona-Warn-App
//

import UIKit

class DismissHandlingNavigationController: UINavigationController, UIAdaptivePresentationControllerDelegate {

	// MARK: - Init

	init() {
		super.init(nibName: nil, bundle: nil)
		self.presentationController?.delegate = self

		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
		}
	}

	override init(rootViewController: UIViewController) {
		if #available(iOS 13.0, *) {
			super.init(rootViewController: rootViewController)
		} else {
			super.init(nibName: nil, bundle: nil)
			self.viewControllers = [rootViewController]
		}

		self.presentationController?.delegate = self

		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
		}
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.presentationController?.delegate = self
		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
		}
	}

	// MARK: - Overrides

	// MARK: - Protocol UIAdaptivePresentationControllerDelegate

	func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
		guard let topViewController = viewControllers.last,
			  let dismissableViewController = topViewController as? DismissHandling  else {
			return
		}

		dismissableViewController.wasAttemptedToBeDismissed()
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

}
