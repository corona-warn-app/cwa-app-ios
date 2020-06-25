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

protocol ExposureSubmissionNavigationControllerDelegate: AnyObject {
	func exposureSubmissionNavigationControllerWillDisappear(_ controller: ExposureSubmissionNavigationController)
}

final class ExposureSubmissionNavigationController: ENANavigationControllerWithFooter, UINavigationControllerDelegate {
	private var testResult: TestResult?

	private(set) var exposureSubmissionService: ExposureSubmissionService?
	private weak var submissionDelegate: ExposureSubmissionNavigationControllerDelegate?

	// MARK: - Initializers.

	init?(
		coder: NSCoder,
		exposureSubmissionService: ExposureSubmissionService,
		submissionDelegate: ExposureSubmissionNavigationControllerDelegate?,
		testResult: TestResult? = nil
	) {
		super.init(coder: coder)
		self.exposureSubmissionService = exposureSubmissionService
		self.submissionDelegate = submissionDelegate
		self.testResult = testResult
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	/// Returns the root view controller, depending on whether we have a
	/// registration token or not.
	private func getRootViewController() -> UIViewController {
		#if UITESTING
		if ProcessInfo.processInfo.arguments.contains("-negativeResult") {
			let vc = AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionTestResultViewController.self)
			vc.testResult = .negative
			return vc
		}

		#else
		// We got a test result and can jump straight into the test result view controller.
		if let service = exposureSubmissionService, testResult != nil, service.hasRegistrationToken() {
			let vc = AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionTestResultViewController.self)
			vc.exposureSubmissionService = service
			vc.testResult = testResult
			return vc
		}
		#endif

		// By default, we show the intro view.
		let vc = AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionIntroViewController.self)
		return vc
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		let rootVC = getRootViewController()
		setViewControllers([rootVC], animated: false)

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
		submissionDelegate?.exposureSubmissionNavigationControllerWillDisappear(self)
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
		dismiss(animated: true)
	}
}

extension ExposureSubmissionNavigationController {
	func navigationController(_: UINavigationController, willShow viewController: UIViewController, animated _: Bool) {
		applyDefaultRightBarButtonItem(to: viewController)
	}
}
