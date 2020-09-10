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
	func showSymptomsScreen()
	func showWarnOthersScreen()
	func showWarnEuropeScreen()
	func showWarnEuropeTravelConfirmationScreen()
	func showWarnEuropeCountrySelectionScreen()
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

	/// - NOTE: We need a strong (aka non-weak) reference here.
	let exposureSubmissionService: ExposureSubmissionService

	var symptomsOnset: SymptomsOnset = .noInformation
	var consentToFederationGiven: Bool = false

	var supportedCountries: [Country] = []
	var visitedCountries: [Country] = []

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
		setupDismissConfirmationOnSwipeDown(for: vc)
	}

	private func present(_ vc: UIViewController) {
		self.navigationController?.present(vc, animated: true)
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

	func showSymptomsScreen() {
		let vc = createSymptomsViewController(
			onPrimaryButtonTap: { [weak self] selectedSymptomsOption in
				switch selectedSymptomsOption {
				case .yes:
					self?.showSymptomsOnsetScreen()
				case .no:
					self?.symptomsOnset = .nonSymptomatic
					self?.showWarnOthersScreen()
				case .preferNotToSay:
					self?.symptomsOnset = .noInformation
					self?.showWarnOthersScreen()
				}
			}
		)

		push(vc)
	}

	func showSymptomsOnsetScreen() {
		let vc = createSymptomsOnsetViewController(
			onPrimaryButtonTap: { [weak self] selectedSymptomsOnsetOption in
				switch selectedSymptomsOnsetOption {
				case .exactDate(let date):
					guard let daysSinceOnset = Calendar.gregorian().dateComponents([.day], from: date, to: Date()).day else {
						fatalError()
					}
					self?.symptomsOnset = .daysSinceOnset(daysSinceOnset)
				case .lastSevenDays:
					self?.symptomsOnset = .lastSevenDays
				case .oneToTwoWeeksAgo:
					self?.symptomsOnset = .oneToTwoWeeksAgo
				case .moreThanTwoWeeksAgo:
					self?.symptomsOnset = .moreThanTwoWeeksAgo
				case .preferNotToSay:
					self?.symptomsOnset = .symptomaticWithUnknownOnset
				}

				self?.showWarnOthersScreen()
			}
		)

		push(vc)
	}

	func showWarnOthersScreen() {
		let vc = createWarnOthersViewController(
			onPrimaryButtonTap: { [weak self] isLoading in
				#if INTEROP
					self?.showWarnEuropeScreen()
				#else
					isLoading(true)
					self?.startSubmitProcess(
						onSuccess: {
							isLoading(false)
							self?.showThankYouScreen()
						},
						onError: {
							isLoading(false)
						}
					)
				#endif
			}
		)

		push(vc)
	}

	func showWarnEuropeScreen() {
		let vc = createWarnEuropeConsentViewController(
			onPrimaryButtonTap: { [weak self] consentToFederationGiven, isLoading in
				self?.consentToFederationGiven = consentToFederationGiven

				if consentToFederationGiven {
					self?.showWarnEuropeTravelConfirmationScreen()
				} else {
					isLoading(true)
					self?.startSubmitProcess(
						onSuccess: {
							isLoading(false)
							self?.showThankYouScreen()
						},
						onError: {
							isLoading(false)
						}
					)
				}
			}
		)

		push(vc)
	}

	func showWarnEuropeTravelConfirmationScreen() {
		let vc = createWarnEuropeTravelConfirmationViewController(
			onPrimaryButtonTap: { [weak self] selectedTravelConfirmationOption, isLoading in
				isLoading(true)
				self?.appConfigurationProvider.appConfiguration { applicationConfiguration in
					isLoading(false)
					#if INTEROP
					// yes, this whole vc is loaded only if INTEROP is set but it's always compiled,
					// so we need to handle this case with preprocessor macros
					guard let supportedCountries = applicationConfiguration?.supportedCountries.compactMap({ Country(countryCode: $0) }) else {
						self?.showENErrorAlert(.noAppConfiguration)
						return
					}
					#else
					let supportedCountries = [Country]()
					#endif
					self?.supportedCountries = supportedCountries

					switch selectedTravelConfirmationOption {
					case .yes:
						self?.showWarnEuropeCountrySelectionScreen()
						return
					case .no:
						self?.visitedCountries = []
					case .preferNotToSay:
						self?.visitedCountries = supportedCountries
					}

					isLoading(true)
					self?.startSubmitProcess(
						onSuccess: {
							isLoading(false)
							self?.showThankYouScreen()
						},
						onError: {
							isLoading(false)
						}
					)
				}
			}
		)

		push(vc)
	}

	func showWarnEuropeCountrySelectionScreen() {
		let vc = createWarnEuropeCountrySelectionViewController(
			onPrimaryButtonTap: { [weak self] selectedCountrySelectionOption, isLoading in
				guard let self = self else { return }

				switch selectedCountrySelectionOption {
				case .visitedCountries(let visitedCountries):
					self.visitedCountries = visitedCountries
				case .preferNotToSay:
					self.visitedCountries = self.supportedCountries
				}

				isLoading(true)
				self.startSubmitProcess(
					onSuccess: {
						isLoading(false)
						self.showThankYouScreen()
					},
					onError: {
						isLoading(false)
					}
				)
			},
			supportedCountries: supportedCountries
		)

		push(vc)
	}

	func showThankYouScreen() {
		let vc = createSuccessViewController()
		push(vc)
	}

	func startSubmitProcess(
		onSuccess: @escaping () -> Void,
		onError: @escaping () -> Void
	) {
		exposureSubmissionService.submitExposure(
			symptomsOnset: symptomsOnset,
			consentToFederation: consentToFederationGiven,
			visitedCountries: visitedCountries,
			completionHandler: { [weak self] error in
				switch error {
				// We continue the regular flow even if there are no keys collected.
				case .none, .noKeys:
					onSuccess()

				// Custom error handling for EN framework related errors.
				case .internal, .unsupported, .rateLimited:
					guard let error = error else {
						logError(message: "error while parsing EN error.")
						return
					}
					self?.showENErrorAlert(error, onCompletion: onError)

				case .some(let error):
					logError(message: "error: \(error.localizedDescription)", level: .error)
					if let alert = self?.navigationController?.setupErrorAlert(message: error.localizedDescription) {
						self?.navigationController?.present(alert, animated: true, completion: {
							onError()
						})
					}
				}
			}
		)
	}

	// MARK: - UI-related helpers.

	/// Instantiates and shows an alert with a "More Info" button for
	/// the EN errors. Assumes that the passed in `error` is either of type
	/// `.internal`, `.unsupported` or `.rateLimited`.
	func showENErrorAlert(_ error: ExposureSubmissionError, onCompletion: (() -> Void)? = nil) {
		logError(message: "error: \(error.localizedDescription)", level: .error)
		guard let alert = createENAlert(error) else { return }

		navigationController?.present(alert, animated: true, completion: {
			onCompletion?()
		})
	}

	/// Creates an error alert for the EN errors.
	func createENAlert(_ error: ExposureSubmissionError) -> UIAlertController? {
		return UIViewController().setupErrorAlert(
			message: error.localizedDescription,
			secondaryActionTitle: error.faqURL != nil ? AppStrings.Common.errorAlertActionMoreInfo : nil,
			secondaryActionCompletion: {
				guard let url = error.faqURL else {
					logError(message: "Unable to open FAQ page.", level: .error)
					return
				}

				UIApplication.shared.open(
					url,
					options: [:]
				)
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
		onPrimaryButtonTap: @escaping (@escaping (Bool) -> Void) -> Void
	) -> ExposureSubmissionWarnOthersViewController {
		AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionWarnOthersViewController.self) { coder -> UIViewController? in
			ExposureSubmissionWarnOthersViewController(coder: coder, onPrimaryButtonTap: onPrimaryButtonTap)
		}
	}

	private func createWarnEuropeConsentViewController(
		onPrimaryButtonTap: @escaping (Bool, @escaping (Bool) -> Void) -> Void
	) -> ExposureSubmissionWarnEuropeConsentViewController {
		AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionWarnEuropeConsentViewController.self) { coder -> UIViewController? in
			ExposureSubmissionWarnEuropeConsentViewController(coder: coder, onPrimaryButtonTap: onPrimaryButtonTap)
		}
	}

	private func createWarnEuropeTravelConfirmationViewController(
		onPrimaryButtonTap: @escaping (ExposureSubmissionWarnEuropeTravelConfirmationViewController.TravelConfirmationOption, @escaping (Bool) -> Void) -> Void
	) -> ExposureSubmissionWarnEuropeTravelConfirmationViewController {
		AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionWarnEuropeTravelConfirmationViewController.self) { coder -> UIViewController? in
			ExposureSubmissionWarnEuropeTravelConfirmationViewController(coder: coder, onPrimaryButtonTap: onPrimaryButtonTap)
		}
	}

	private func createWarnEuropeCountrySelectionViewController(
		onPrimaryButtonTap: @escaping (ExposureSubmissionWarnEuropeCountrySelectionViewController.CountrySelectionOption, @escaping (Bool) -> Void) -> Void,
		supportedCountries: [Country]
	) -> ExposureSubmissionWarnEuropeCountrySelectionViewController {
		AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionWarnEuropeCountrySelectionViewController.self) { coder -> UIViewController? in
			ExposureSubmissionWarnEuropeCountrySelectionViewController(coder: coder, onPrimaryButtonTap: onPrimaryButtonTap, supportedCountries: supportedCountries)
		}
	}

	private func createSuccessViewController() -> ExposureSubmissionSuccessViewController {
		AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionSuccessViewController.self) { coder -> UIViewController? in
			ExposureSubmissionSuccessViewController(coder: coder, coordinator: self)
		}
	}

}

extension ExposureSubmissionCoordinator: UIAdaptivePresentationControllerDelegate {
	func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
		dismiss()
	}
}
