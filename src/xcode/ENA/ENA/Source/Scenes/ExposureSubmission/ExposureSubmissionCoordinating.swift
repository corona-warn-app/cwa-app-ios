//
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
//

import Foundation
import UIKit

/// Coordinator for the exposure submission flow.
/// This protocol hides the creation of view controllers and their transitions behind a slim interface.
protocol ExposureSubmissionCoordinating: class {

	// MARK: - Attributes.

	/// Delegate that is called for life-cycle events of the coordinator.
	var delegate: ExposureSubmissionCoordinatorDelegate? { get set }

	// MARK: - Navigation.

	/// Starts the coordinator and displays the initial root view controller.
	/// The underlying implementation may decide which initial screen to show, currently the following options are possible:
	/// - Case 1: When a valid test result is provided, the coordinator shows the test result screen.
	/// - Case 2: (DEFAULT) The coordinator shows the intro screen.
	/// - Case 3: (UI-Testing) The coordinator may be configured to show other screens for UI-Testing.
	/// For more information on the usage and configuration of the initial screen, check the concrete implementation of the method.
	func start(with result: TestResult?)
	func dismiss()

	func showOverviewScreen()
	func showTestResultScreen(with result: TestResult)
	func showHotlineScreen()
	func showTanScreen()
	func showQRScreen(qrScannerDelegate: ExposureSubmissionQRScannerDelegate)
	func showWarnOthersScreen()
	func showThankYouScreen()
}

/// This delegate allows a class to be notified for life-cycle events of the coordinator.
protocol ExposureSubmissionCoordinatorDelegate: class {
	func exposureSubmissionCoordinatorWillDisappear(_ coordinator: ExposureSubmissionCoordinating)
}

/// Concrete implementation of the ExposureSubmissionCoordinator protocol.
class ExposureSubmissionCoordinator: ExposureSubmissionCoordinating {

	// MARK: - Attributes.

	/// - NOTE: The delegate is called by the `viewWillDisappear(_:)` method of the `navigationController`.
	weak var delegate: ExposureSubmissionCoordinatorDelegate?
	weak var parentNavigationController: UINavigationController?

	/// - NOTE: We keep a weak reference here to avoid a reference cycle.
	///  (the navigationController holds a strong reference to the coordinator).
	weak var navigationController: UINavigationController?

	/// - NOTE: We need a strong (aka non-weak) reference here.
	let exposureSubmissionService: ExposureSubmissionService

	// MARK: - Initializers.

	init(
		parentNavigationController: UINavigationController,
		exposureSubmissionService: ExposureSubmissionService,
		delegate: ExposureSubmissionCoordinatorDelegate? = nil
	) {
		self.parentNavigationController = parentNavigationController
		self.exposureSubmissionService = exposureSubmissionService
		self.delegate = delegate
	}
}

// MARK: - Navigation.

extension ExposureSubmissionCoordinator {
	
	// MARK: - Helpers.

	private func push(_ vc: UIViewController) {
		self.navigationController?.pushViewController(vc, animated: true)
	}

	private func present(_ vc: UIViewController) {
		self.navigationController?.present(vc, animated: true)
	}

	/// This method selects the correct initial view controller among the following options:
	/// Option 1: (only for UITESTING) if the `-negativeResult` flag was passed, return ExposureSubmissionTestResultViewController
	/// Option 2: if a test result was passed, the method checks further preconditions (e.g. the exposure submission service has a registration token)
	/// and returns an ExposureSubmissionTestResultViewController.
	/// Option 3: (default) return the ExposureSubmissionIntroViewController.
	private func getInitialViewController(with result: TestResult? = nil) -> UIViewController {
		#if UITESTING
		if ProcessInfo.processInfo.arguments.contains("-negativeResult") {
			return createTestResultViewController(with: .negative)
		}

		#else
		// We got a test result and can jump straight into the test result view controller.
		if let result = result, exposureSubmissionService.hasRegistrationToken() {
			return createTestResultViewController(with: result)
		}
		#endif

		// By default, we show the intro view.
		return createIntroViewController()
	}

	// MARK: - Public API.

	func start(with result: TestResult? = nil) {
		let initialVC = getInitialViewController(with: result)
		guard let parentNavigationController = parentNavigationController else {
			log(message: "Parent navigation controller not set.", level: .error, file: #file, line: #line, function: #function)
			return
		}

		/// The navigation controller keeps a strong reference to the coordinator. The coordinator only reaches reference count 0
		/// when UIKit dismisses the navigationController.
		let navigationController = createNavigationController(rootViewController: initialVC)
		parentNavigationController.present(navigationController, animated: true)
		self.navigationController = navigationController
	}

	func dismiss() {
		navigationController?.dismiss(animated: true)
	}

	func showOverviewScreen() {
		let vc = createOverviewViewController()
		push(vc)
	}

	func showTestResultScreen(with result: TestResult) {
		let vc = createTestResultViewController(with: result)
		push(vc)
	}

	func showHotlineScreen() {
		let vc = createHotlineViewController()
		push(vc)
	}
	func showTanScreen() {
		let vc = createTanInputViewController()
		push(vc)
	}

	func showQRScreen(qrScannerDelegate: ExposureSubmissionQRScannerDelegate) {
		let vc = createQRScannerViewController(qrScannerDelegate: qrScannerDelegate)
		present(vc)
	}

	func showWarnOthersScreen() {
		let vc = createWarnOthersViewController()
		push(vc)
	}

	func showThankYouScreen() {
		let vc = createSuccessViewController()
		push(vc)
	}
}

// MARK: - Creation.

extension ExposureSubmissionCoordinator {

	private func createNavigationController(rootViewController vc: UIViewController) -> ExposureSubmissionNavigationController {
		return AppStoryboard.exposureSubmission.initiateInitial { coder in
			ExposureSubmissionNavigationController(coder: coder, coordinator: self, rootViewController: vc)
		}
	}

	private func createIntroViewController() -> ExposureSubmissionIntroViewController {
		AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionIntroViewController.self) { coder -> UIViewController? in
			ExposureSubmissionIntroViewController(coder: coder, coordinator: self)
		}
	}

	private func createOverviewViewController() -> ExposureSubmissionOverviewViewController {
		AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionOverviewViewController.self) { coder in
			ExposureSubmissionOverviewViewController(coder: coder, coordinator: self, exposureSubmissionService: self.exposureSubmissionService)
		}

	}

	private func createTanInputViewController() -> ExposureSubmissionTanInputViewController {
		AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionTanInputViewController.self) { coder -> UIViewController? in
			ExposureSubmissionTanInputViewController(coder: coder, coordinator: self, exposureSubmissionService: self.exposureSubmissionService)
		}
	}

	private func createHotlineViewController() -> ExposureSubmissionHotlineViewController {
		AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionHotlineViewController.self) { coder -> UIViewController? in
			ExposureSubmissionHotlineViewController(coder: coder, coordinator: self)
		}
	}

	private func createTestResultViewController(with result: TestResult) -> ExposureSubmissionTestResultViewController {
		AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionTestResultViewController.self) { coder -> UIViewController? in
			ExposureSubmissionTestResultViewController(
				coder: coder,
				coordinator: self,
				exposureSubmissionService: self.exposureSubmissionService,
				testResult: result
			)
		}
	}

	private func createQRScannerViewController(qrScannerDelegate: ExposureSubmissionQRScannerDelegate) -> ExposureSubmissionQRScannerNavigationController {
		AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionQRScannerNavigationController.self) { coder -> UIViewController? in
			let vc = ExposureSubmissionQRScannerNavigationController(coder: coder, coordinator: self, exposureSubmissionService: self.exposureSubmissionService)
			vc?.scannerViewController?.delegate = qrScannerDelegate
			return vc
		}
	}

	private func createWarnOthersViewController() -> ExposureSubmissionWarnOthersViewController {
		AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionWarnOthersViewController.self) { coder -> UIViewController? in
			ExposureSubmissionWarnOthersViewController(coder: coder, coordinator: self, exposureSubmissionService: self.exposureSubmissionService)
		}
	}

	private func createSuccessViewController() -> ExposureSubmissionSuccessViewController {
		AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionSuccessViewController.self) { coder -> UIViewController? in
			ExposureSubmissionSuccessViewController(coder: coder, coordinator: self)
		}
	}
}
