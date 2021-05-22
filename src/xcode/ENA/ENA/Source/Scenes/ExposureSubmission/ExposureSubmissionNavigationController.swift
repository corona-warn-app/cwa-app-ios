//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

protocol DismissHandling {
	/// if a view controller fulfils this protocol and is member a ExposureSubmissionNavigationController and
	/// on top of the view controllers stack - presentDismiss action (swipe down or close button) will call this
	/// function
	/// otherwise no reaction is possible and the dismiss logic depends on the navigation controller
	func wasAttemptedToBeDismissed()

	/// default close button to respect the dismissHandling protocol
	var dismissHandlingCloseBarButton: UIBarButtonItem { get }
	/// close button to respect display mode and dismissHandling protocol
	func dismissHandlingCloseBarButton(_ mode: CloseBarButtonItem.Mode) -> UIBarButtonItem
}


extension DismissHandling {

	/// default implementation to avoid dismiss by pulling down
	func wasAttemptedToBeDismissed() {}

	/// default implementation of dismissHandlingCloseButton
	var dismissHandlingCloseBarButton: UIBarButtonItem {
		dismissHandlingCloseBarButton(.normal)
	}

	/// default implementation of dismissHandling CloseButton with display mode
	func dismissHandlingCloseBarButton(_ mode: CloseBarButtonItem.Mode) -> UIBarButtonItem {
		CloseBarButtonItem(
			mode: mode,
			onTap: {
				self.wasAttemptedToBeDismissed()
			}
		)
	}

}

final class ExposureSubmissionNavigationController: ENANavigationControllerWithFooter {

	// MARK: - Init

	init(
		coordinator: ExposureSubmissionCoordinator? = nil,
		dismissClosure: @escaping () -> Void,
		rootViewController: UIViewController
	) {
		self.coordinator = coordinator
		self.dismissClosure = dismissClosure
		super.init(rootViewController: rootViewController)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationBar.accessibilityIdentifier = AccessibilityIdentifiers.General.exposureSubmissionNavigationControllerTitle
		navigationBar.prefersLargeTitles = true
	}

	// MARK: - Protocol UIAdaptivePresentationControllerDelegate

	/// override to implement an other default handling - call dismissClosure()
	override func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
		guard let topViewController = viewControllers.last,
			  let dismissAbleViewController = topViewController as? DismissHandling  else {
			Log.debug("ViewController found doesn't conforms to protocol DismissHandling -> stop")
			dismissClosure()
			return
		}

		dismissAbleViewController.wasAttemptedToBeDismissed()
	}

	// MARK: - Private

	private let coordinator: ExposureSubmissionCoordinator?
	private let dismissClosure: () -> Void

}
