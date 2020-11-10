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
	func showTanScreen()
	func showThankYouScreen()

}

/// This delegate allows a class to be notified for life-cycle events of the coordinator.
protocol ExposureSubmissionCoordinatorDelegate: class {
	func exposureSubmissionCoordinatorWillDisappear(_ coordinator: ExposureSubmissionCoordinating)
}

/// Concrete implementation of the ExposureSubmissionCoordinator protocol.
class ExposureSubmissionCoordinator: NSObject, ExposureSubmissionCoordinating, RequiresAppDependencies {

	// MARK: - Attributes.

	/// - NOTE: The delegate is called by the `viewWillDisappear(_:)` method of the `navigationController`.
	weak var delegate: ExposureSubmissionCoordinatorDelegate?
	weak var parentNavigationController: UINavigationController?

	/// - NOTE: We keep a weak reference here to avoid a reference cycle.
	///  (the navigationController holds a strong reference to the coordinator).
	weak var navigationController: UINavigationController?

	weak var presentedViewController: UIViewController?

	var model: ExposureSubmissionCoordinatorModel!
	
	let warnOthers: WarnOthersRemindable

	// MARK: - Initializers.

	init(
		warnOthers: WarnOthersRemindable,
		parentNavigationController: UINavigationController,
		exposureSubmissionService: ExposureSubmissionService,
		delegate: ExposureSubmissionCoordinatorDelegate? = nil
	) {
		self.parentNavigationController = parentNavigationController
		self.delegate = delegate
		self.warnOthers = warnOthers

		super.init()

		self.model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			appConfigurationProvider: appConfigurationProvider
		)
	}

}

// MARK: - Navigation.

extension ExposureSubmissionCoordinator {
	
	// MARK: - Helpers.

	private func push(_ vc: UIViewController) {
		self.navigationController?.pushViewController(vc, animated: true)
		setupDismissConfirmationOnSwipeDown(for: vc)
	}

	private func setupDismissConfirmationOnSwipeDown(for vc: UIViewController) {
		guard let vc = vc as? RequiresDismissConfirmation else {
			return
		}

		vc.navigationController?.presentationController?.delegate = self
		vc.isModalInPresentation = true
	}

	/// This method selects the correct initial view controller among the following options:
	/// Option 1: (only for UITESTING) if the `-negativeResult` flag was passed, return ExposureSubmissionTestResultViewController
	/// Option 2: if a test result was passed, the method checks further preconditions (e.g. the exposure submission service has a registration token)
	/// and returns an ExposureSubmissionTestResultViewController.
	/// Option 3: (default) return the ExposureSubmissionIntroViewController.
	private func getInitialViewController(with result: TestResult? = nil) -> UIViewController {
		#if DEBUG
		if isUITesting, ProcessInfo.processInfo.arguments.contains("-negativeResult") {
			return createTestResultViewController(with: .negative)
		}
		#endif
		// We got a test result and can jump straight into the test result view controller.
		if let result = result, model.exposureSubmissionServiceHasRegistrationToken {
			return createTestResultViewController(with: result)
		}

		// By default, we show the intro view.
		return createIntroViewController()
	}

	// MARK: - Public API.

	func start(with result: TestResult? = nil) {
		let initialVC = getInitialViewController(with: result)
		guard let parentNavigationController = parentNavigationController else {
			Log.error("Parent navigation controller not set.", log: .ui)
			return
		}

		/// The navigation controller keeps a strong reference to the coordinator. The coordinator only reaches reference count 0
		/// when UIKit dismisses the navigationController.
		let navigationController = createNavigationController(rootViewController: initialVC)
		parentNavigationController.present(navigationController, animated: true)
		self.navigationController = navigationController
	}

	func dismiss() {
		guard let presentedViewController = navigationController?.viewControllers.last else { return }
		guard let vc = presentedViewController as? RequiresDismissConfirmation else {
			navigationController?.dismiss(animated: true)
			return
		}

		vc.attemptDismiss { [weak self] shouldDismiss in
			if shouldDismiss { self?.navigationController?.dismiss(animated: true) }
		}
	}

	func showOverviewScreen() {
		let vc = ExposureSubmissionOverviewViewController(
			onQRCodeButtonTap: { [weak self] in self?.showQRInfoScreen() },
			onTANButtonTap: { [weak self] in self?.showTanScreen() },
			onHotlineButtonTap: { [weak self] in self?.showHotlineScreen() }
		)
		push(vc)
	}

	func showTestResultScreen(with testResult: TestResult) {
		let vc = createTestResultViewController(with: testResult)
		push(vc)
	}

	func createTestResultViewController(with testResult: TestResult) -> ExposureSubmissionTestResultViewController {
		
		return ExposureSubmissionTestResultViewController(
			viewModel: .init(
				warnOthers: warnOthers,
				testResult: testResult,
				exposureSubmissionService: model.exposureSubmissionService,
				onContinueWithSymptomsFlowButtonTap: { [weak self] isLoading in
					self?.model.checkStateAndLoadCountries(
						isLoading: isLoading,
						onSuccess: {
							self?.showSymptomsScreen()
						}, onError: { error in
							self?.showErrorAlert(for: error)
						}
					)
				},
				onContinueWithoutSymptomsFlowButtonTap: { [weak self] isLoading in
					self?.model.checkStateAndLoadCountries(
						isLoading: isLoading,
						onSuccess: {
							self?.showWarnOthersScreen()
						},
						onError: { error in
							self?.showErrorAlert(for: error)
						}
					)
				},
				onTestDeleted: { [weak self] in
					self?.dismiss()
				}
			)
		)
	}

	func showHotlineScreen() {
		let vc = createHotlineViewController()
		push(vc)
	}

	func showTanScreen() {
		let vc = createTanInputViewController()
		push(vc)
	}

	private func showQRInfoScreen() {
		let vc = ExposureSubmissionQRInfoViewController(onPrimaryButtonTap: { [weak self] isLoading in
			self?.showDisclaimer(isLoading: isLoading)
		})
		push(vc)
	}

	private func showDisclaimer(isLoading: @escaping (Bool) -> Void) {
		let alert = UIAlertController(
			title: AppStrings.ExposureSubmission.dataPrivacyTitle,
			message: AppStrings.ExposureSubmission.dataPrivacyDisclaimer,
			preferredStyle: .alert
		)

		let acceptAction = UIAlertAction(
			title: AppStrings.ExposureSubmission.dataPrivacyAcceptTitle,
			style: .default,
			handler: { [weak self] _ in
				self?.model.exposureSubmissionService.acceptPairing()
				self?.showQRScreen(isLoading: isLoading)
			}
		)

		alert.addAction(acceptAction)

		alert.addAction(
			.init(
				title: AppStrings.ExposureSubmission.dataPrivacyDontAcceptTitle,
				style: .cancel,
				handler: { _ in
					alert.dismiss(animated: true)
				}
			)
		)
		alert.preferredAction = acceptAction

		navigationController?.present(alert, animated: true)
	}

	private func showQRScreen(isLoading: @escaping (Bool) -> Void) {
		let scannerViewController = ExposureSubmissionQRScannerViewController(
			onSuccess: { [weak self] deviceRegistrationKey in
				self?.presentedViewController?.dismiss(animated: true) {
					self?.getTestResults(for: deviceRegistrationKey, isLoading: isLoading)
				}
			},
			onError: { [weak self] error, reactivateScanning in
				switch error {
				case .cameraPermissionDenied:
					DispatchQueue.main.async {
						let alert = UIAlertController.errorAlert(message: error.localizedDescription, completion: {
							self?.presentedViewController?.dismiss(animated: true)
						})
						self?.presentedViewController?.present(alert, animated: true)
					}
				case .codeNotFound:
					DispatchQueue.main.async {
						let alert = UIAlertController.errorAlert(
							title: AppStrings.ExposureSubmissionError.qrAlreadyUsedTitle,
							message: AppStrings.ExposureSubmissionError.qrAlreadyUsed,
							okTitle: AppStrings.Common.alertActionCancel,
							secondaryActionTitle: AppStrings.Common.alertActionRetry,
							completion: { [weak self] in
								self?.presentedViewController?.dismiss(animated: true)
							},
							secondaryActionCompletion: { reactivateScanning() }
						)
						self?.presentedViewController?.present(alert, animated: true)
					}
				default:
					Log.error("QRScannerError.other occurred.", log: .ui)
				}
			},
			onCancel: { [weak self] in
				self?.presentedViewController?.dismiss(animated: true)
			}
		)

		let qrScannerNavigationController = UINavigationController(rootViewController: scannerViewController)
		qrScannerNavigationController.modalPresentationStyle = .fullScreen

		navigationController?.present(qrScannerNavigationController, animated: true)
		presentedViewController = qrScannerNavigationController
	}

	func showSymptomsScreen() {
		let vc = createSymptomsViewController(
			onPrimaryButtonTap: { [weak self] selectedSymptomsOption in
				guard let self = self else { return }

				self.model.symptomsOptionSelected(selectedSymptomsOption)
				self.model.shouldShowSymptomsOnsetScreen ? self.showSymptomsOnsetScreen() : self.showWarnOthersScreen()
			}
		)

		push(vc)
	}

	private func showSymptomsOnsetScreen() {
		let vc = createSymptomsOnsetViewController(
			onPrimaryButtonTap: { [weak self] selectedSymptomsOnsetOption in
				self?.model.symptomsOnsetOptionSelected(selectedSymptomsOnsetOption)
				self?.showWarnOthersScreen()
			}
		)

		push(vc)
	}

	func showWarnOthersScreen() {
		let vc = createWarnOthersViewController(
			supportedCountries: model.supportedCountries,
			onPrimaryButtonTap: { [weak self] isLoading in
				self?.model.warnOthersConsentGiven(
					isLoading: isLoading,
					onSuccess: { self?.showThankYouScreen() },
					onError: { error in
						self?.showErrorAlert(for: error)
					}
				)
			}
		)

		push(vc)
	}

	func showThankYouScreen() {
		let vc = createSuccessViewController()
		push(vc)
	}

	// MARK: - UI-related helpers.

	private func showErrorAlert(for error: ExposureSubmissionError, onCompletion: (() -> Void)? = nil) {
		Log.error("error: \(error.localizedDescription)", log: .ui)

		let alert = UIAlertController.errorAlert(
			message: error.localizedDescription,
			secondaryActionTitle: error.faqURL != nil ? AppStrings.Common.errorAlertActionMoreInfo : nil,
			secondaryActionCompletion: {
				guard let url = error.faqURL else {
					Log.error("Unable to open FAQ page.", log: .api)
					return
				}

				UIApplication.shared.open(
					url,
					options: [:]
				)
			}
		)

		navigationController?.present(alert, animated: true, completion: {
			onCompletion?()
		})
	}

	private func getTestResults(for key: DeviceRegistrationKey, isLoading: @escaping (Bool) -> Void) {
		model.getTestResults(
			for: key,
			isLoading: isLoading,
			onSuccess: { [weak self] in self?.showTestResultScreen(with: $0) },
			onError: { [weak self] error in
				let alert: UIAlertController

				switch error {
				case .qrDoesNotExist:
					alert = UIAlertController.errorAlert(
						title: AppStrings.ExposureSubmissionError.qrNotExistTitle,
						message: error.localizedDescription
					)

					self?.navigationController?.present(alert, animated: true, completion: nil)
				case .qrAlreadyUsed:
					alert = UIAlertController.errorAlert(
						title: AppStrings.ExposureSubmissionError.qrAlreadyUsedTitle,
						message: error.localizedDescription
					)
				case .qrExpired:
					alert = UIAlertController.errorAlert(
						title: AppStrings.ExposureSubmission.qrCodeExpiredTitle,
						message: error.localizedDescription
					)
				default:
					alert = UIAlertController.errorAlert(
						message: error.localizedDescription,
						secondaryActionTitle: AppStrings.Common.alertActionRetry,
						secondaryActionCompletion: {
							self?.getTestResults(for: key, isLoading: isLoading)
						}
					)
				}

				self?.navigationController?.present(alert, animated: true, completion: nil)

				Log.error("An error occurred during result fetching: \(error)", log: .ui)
			}
		)
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

	private func createTanInputViewController() -> ExposureSubmissionTanInputViewController {
		AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionTanInputViewController.self) { coder -> UIViewController? in
			ExposureSubmissionTanInputViewController(coder: coder, coordinator: self, exposureSubmissionService: self.model.exposureSubmissionService)
		}
	}

	private func createHotlineViewController() -> ExposureSubmissionHotlineViewController {
		AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionHotlineViewController.self) { coder -> UIViewController? in
			ExposureSubmissionHotlineViewController(coder: coder, coordinator: self)
		}
	}

	private func createSymptomsViewController(
		onPrimaryButtonTap: @escaping (ExposureSubmissionSymptomsViewController.SymptomsOption) -> Void
	) -> ExposureSubmissionSymptomsViewController {
		AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionSymptomsViewController.self) { coder -> UIViewController? in
			ExposureSubmissionSymptomsViewController(coder: coder, onPrimaryButtonTap: onPrimaryButtonTap)
		}
	}

	private func createSymptomsOnsetViewController(
		onPrimaryButtonTap: @escaping (ExposureSubmissionSymptomsOnsetViewController.SymptomsOnsetOption) -> Void
	) -> ExposureSubmissionSymptomsOnsetViewController {
		AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionSymptomsOnsetViewController.self) { coder -> UIViewController? in
			ExposureSubmissionSymptomsOnsetViewController(coder: coder, onPrimaryButtonTap: onPrimaryButtonTap)
		}
	}

	private func createWarnOthersViewController(
		supportedCountries: [Country],
		onPrimaryButtonTap: @escaping (@escaping (Bool) -> Void) -> Void
	) -> ExposureSubmissionWarnOthersViewController {
		AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionWarnOthersViewController.self) { coder -> UIViewController? in
			ExposureSubmissionWarnOthersViewController(coder: coder, supportedCountries: supportedCountries, onPrimaryButtonTap: onPrimaryButtonTap)
		}
	}

	private func createSuccessViewController() -> ExposureSubmissionSuccessViewController {
		AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionSuccessViewController.self) { coder -> UIViewController? in
			ExposureSubmissionSuccessViewController(warnOthers: self.warnOthers, coder: coder, coordinator: self)
		}
	}

}

extension ExposureSubmissionCoordinator: UIAdaptivePresentationControllerDelegate {
	func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
		dismiss()
	}
}
