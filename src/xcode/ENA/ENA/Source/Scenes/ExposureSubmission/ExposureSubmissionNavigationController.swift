// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import Foundation
import UIKit

final class ExposureSubmissionNavigationController: ENANavigationControllerWithFooter, UINavigationControllerDelegate {

	// MARK: - Attributes.

	private let coordinator: ExposureSubmissionCoordinating
	private var rootViewController: UIViewController?

	// MARK: - Initializers.

	init?(coder: NSCoder, coordinator: ExposureSubmissionCoordinating, rootViewController: UIViewController? = nil) {
		self.coordinator = coordinator
		self.rootViewController = rootViewController
		super.init(coder: coder)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		if let rootVC = rootViewController {
			setViewControllers([rootVC], animated: false)
		}

		let closeButton = UIButton(type: .custom)
		closeButton.setImage(UIImage(named: "Icons - Close"), for: .normal)
		closeButton.setImage(UIImage(named: "Icons - Close - Tap"), for: .highlighted)
		closeButton.addTarget(self, action: #selector(close), for: .primaryActionTriggered)

		let barButtonItem = UIBarButtonItem(customView: closeButton)
		barButtonItem.accessibilityLabel = AppStrings.AccessibilityLabel.close
		barButtonItem.accessibilityIdentifier = AccessibilityIdentifiers.AccessibilityLabel.close

		navigationItem.rightBarButtonItem = barButtonItem
		navigationBar.accessibilityLabel = AccessibilityIdentifiers.General.exposureSubmissionNavigationControllerTitle

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

extension ExposureSubmissionNavigationController {
	func navigationController(_: UINavigationController, willShow viewController: UIViewController, animated _: Bool) {
		applyDefaultRightBarButtonItem(to: viewController)
	}
}
