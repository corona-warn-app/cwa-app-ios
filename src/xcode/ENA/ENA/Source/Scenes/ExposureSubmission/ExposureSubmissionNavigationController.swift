//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

protocol DismissHandling {
	/// if a view controller fulfulls this protocol and is member a ExposureSubmissionNavigationController and
	/// on top of the viewcontrollers stack - presentDismiss action (swipe down or close button) will call this
	/// function
	/// otherwise no reaction is possible and the dismiss logic depends on the navigation controller
	func wasAttemptedToBeDismissed()
}

final class ExposureSubmissionNavigationController: ENANavigationControllerWithFooter, UINavigationControllerDelegate, UIAdaptivePresentationControllerDelegate {

	// MARK: - Init

	init(
		coordinator: ExposureSubmissionCoordinating? = nil,
		dismissClosure: @escaping () -> Void,
		rootViewController: UIViewController
	) {
		self.coordinator = coordinator
		self.dismissClosure = dismissClosure
		super.init(rootViewController: rootViewController)
		// init default UIAdaptivePresentation delegate
		self.presentationController?.delegate = self
		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
		}
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		let closeButton = UIButton(type: .custom)
		closeButton.setImage(UIImage(named: "Icons - Close"), for: .normal)
		closeButton.setImage(UIImage(named: "Icons - Close - Tap"), for: .highlighted)
		closeButton.addTarget(self, action: #selector(closeButtonHit), for: .primaryActionTriggered)

		let barButtonItem = UIBarButtonItem(customView: closeButton)
		barButtonItem.accessibilityLabel = AppStrings.AccessibilityLabel.close
		barButtonItem.accessibilityIdentifier = AccessibilityIdentifiers.AccessibilityLabel.close

		navigationItem.rightBarButtonItem = barButtonItem
		navigationBar.accessibilityIdentifier = AccessibilityIdentifiers.General.exposureSubmissionNavigationControllerTitle
		navigationBar.prefersLargeTitles = true

		delegate = self
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		applyDefaultRightBarButtonItem(to: topViewController)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		// Check if the ExposureSubmissionNavigationController is popped from its parent.
		guard self.isMovingFromParent || self.isBeingDismissed,
			  let coordinator = coordinator else { return }
		coordinator.delegate?.exposureSubmissionCoordinatorWillDisappear(coordinator)
	}

	// MARK: - Protocol UINavigationControllerDelegate

	func navigationController(_: UINavigationController, willShow viewController: UIViewController, animated _: Bool) {
		applyDefaultRightBarButtonItem(to: viewController)
	}

	// MARK: - Protocol UIAdaptivePresentationControllerDelegate

	func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
		guard let topViewController = viewControllers.last,
			  let dismissableViewController = topViewController as? DismissHandling  else {
			Log.debug("ViewController found doesn't conforms to protocol DismissHandling -> stop")
			dismissClosure()
			return
		}

		dismissableViewController.wasAttemptedToBeDismissed()
	}

	// MARK: - Private

	private let coordinator: ExposureSubmissionCoordinating?
	private let dismissClosure: () -> Void

	private func applyDefaultRightBarButtonItem(to viewController: UIViewController?) {
		if let viewController = viewController,
		   viewController.navigationItem.rightBarButtonItem == nil ||
			viewController.navigationItem.rightBarButtonItem == navigationItem.rightBarButtonItem {
			viewController.navigationItem.rightBarButtonItem = navigationItem.rightBarButtonItem
		}
	}

	@objc
	func closeButtonHit() {
		guard let presentationController = self.presentationController else { return }
		presentationControllerDidAttemptToDismiss(presentationController)
	}
}
