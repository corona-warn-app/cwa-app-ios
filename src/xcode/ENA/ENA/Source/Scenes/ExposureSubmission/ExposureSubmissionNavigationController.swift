//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class ExposureSubmissionNavigationController: ENANavigationControllerWithFooter, UINavigationControllerDelegate {

	// MARK: - Init

	init(
		coordinator: ExposureSubmissionCoordinating,
		rootViewController: UIViewController
	) {
		self.coordinator = coordinator
		super.init(rootViewController: rootViewController)
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
		closeButton.addTarget(self, action: #selector(close), for: .primaryActionTriggered)

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
		guard self.isMovingFromParent || self.isBeingDismissed else { return }
		coordinator.delegate?.exposureSubmissionCoordinatorWillDisappear(coordinator)
	}

	// MARK: - Protocol UINavigationControllerDelegate

	func navigationController(_: UINavigationController, willShow viewController: UIViewController, animated _: Bool) {
		applyDefaultRightBarButtonItem(to: viewController)
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let coordinator: ExposureSubmissionCoordinating

	private func applyDefaultRightBarButtonItem(to viewController: UIViewController?) {
		if let viewController = viewController,
			viewController.navigationItem.rightBarButtonItem == nil ||
				viewController.navigationItem.rightBarButtonItem == navigationItem.rightBarButtonItem {
			viewController.navigationItem.rightBarButtonItem = navigationItem.rightBarButtonItem
		}
	}

	@objc
	func close() {
		self.coordinator.dismiss()
	}
}
