//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine
import ExposureNotification

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
	/// - Case 2: (DEFAULT) The coordinator shows the screen "Fetch Test Result and Warn Others".
	/// - Case 3: (UI-Testing) The coordinator may be configured to show other screens for UI-Testing.
	/// For more information on the usage and configuration of the initial screen, check the concrete implementation of the method.
	func start(with result: TestResult?)
	func dismiss()
	func showTestResultScreen(with result: TestResult)
	func showTanScreen()
}

/// This delegate allows a class to be notified for life-cycle events of the coordinator.
protocol ExposureSubmissionCoordinatorDelegate: class {
	func exposureSubmissionCoordinatorWillDisappear(_ coordinator: ExposureSubmissionCoordinating)
}

// swiftlint:disable file_length
/// Concrete implementation of the ExposureSubmissionCoordinator protocol.
// swiftlint:disable:next type_body_length
class ExposureSubmissionCoordinator: NSObject, ExposureSubmissionCoordinating, RequiresAppDependencies {

	// MARK: - Init

	init(
		warnOthersReminder: WarnOthersRemindable,
		parentNavigationController: UINavigationController,
		exposureSubmissionService: ExposureSubmissionService,
		delegate: ExposureSubmissionCoordinatorDelegate? = nil
	) {
		self.parentNavigationController = parentNavigationController
		self.delegate = delegate
		self.warnOthersReminder = warnOthersReminder
		
		super.init()

		model = ExposureSubmissionCoordinatorModel(exposureSubmissionService: exposureSubmissionService)
	}

	// MARK: - Protocol ExposureSubmissionCoordinating

	/// - NOTE: The delegate is called by the `viewWillDisappear(_:)` method of the `navigationController`.
	weak var delegate: ExposureSubmissionCoordinatorDelegate?

	func start(with result: TestResult? = nil) {
		let initialVC = getInitialViewController(with: result)
		guard let parentNavigationController = parentNavigationController else {
			Log.error("Parent navigation controller not set.", log: .ui)
			return
		}

		/// The navigation controller keeps a strong reference to the coordinator. The coordinator only reaches reference count 0
		/// when UIKit dismisses the navigationController.
		let exposureSubmissionNavigationController = ExposureSubmissionNavigationController(
			coordinator: self,
			dismissClosure: { [weak self] in
				self?.navigationController?.dismiss(animated: true)
			},
			rootViewController: initialVC
		)
		parentNavigationController.present(exposureSubmissionNavigationController, animated: true)
		navigationController = exposureSubmissionNavigationController
	}

	func dismiss() {
		navigationController?.dismiss(animated: true)
	}

	func showTestResultScreen(with testResult: TestResult) {
		let vc = createTestResultViewController(with: testResult)
		push(vc)
	}

	func showTanScreen() {
		let tanInputViewModel = TanInputViewModel(
			exposureSubmissionService: model.exposureSubmissionService,
			presentInvalidTanAlert: { [weak self] localizedDescription, completion  in
				self?.presentTanInvalidAlert(localizedDescription: localizedDescription, completion: completion)
			},
			tanSuccessfullyTransferred: { [weak self] in
				// A TAN always indicates a positive test result.
				self?.showTestResultScreen(with: .positive)
			}
		)

		let vc = TanInputViewController(
			viewModel: tanInputViewModel
		)
		push(vc)
	}

	/// This method selects the correct initial view controller among the following options:
	/// Option 1: (only for UITESTING) if the `-negativeResult` flag was passed, return ExposureSubmissionTestResultViewController
	/// Option 2: if a test result was passed, the method checks further preconditions (e.g. the exposure submission service has a registration token)
	/// and returns an ExposureSubmissionTestResultViewController.
	/// Option 3: (default) return the ExposureSubmissionIntroViewController.
	func getInitialViewController(with result: TestResult? = nil) -> UIViewController {
		#if DEBUG
		if isUITesting {
			model.exposureSubmissionService.isSubmissionConsentGiven = false
			if UserDefaults.standard.string(forKey: "isSubmissionConsentGiven") == "YES" {
				model.exposureSubmissionService.isSubmissionConsentGiven = true
			}

			if let testResultStringValue = UserDefaults.standard.string(forKey: "testResult"),
			   let testResult = TestResult(stringValue: testResultStringValue) {
				return createTestResultViewController(with: testResult)
			}
		}
		#endif

		// We got a test result and can jump straight into the test result view controller.
		if let testResult = result, model.exposureSubmissionService.hasRegistrationToken {
			// For a positive test result we show the test result available screen if it wasn't shown before
			if testResult == .positive {
				if !warnOthersReminder.positiveTestResultWasShown {
					return createTestResultAvailableViewController(testResult: testResult)
				} else {
					return createWarnOthersViewController()
				}
			} else {
				return createTestResultViewController(with: testResult)
			}
		}

		// By default, we show the intro view.
		let viewModel = ExposureSubmissionIntroViewModel(
			onQRCodeButtonTap: { [weak self] isLoading in
				self?.model.exposureSubmissionService.loadSupportedCountries(
					isLoading: isLoading,
					onSuccess: { supportedCountries in
						self?.showQRInfoScreen(supportedCountries: supportedCountries)
					}
				)
			},
			onTANButtonTap: { [weak self] in self?.showTanScreen() },
			onHotlineButtonTap: { [weak self] in self?.showHotlineScreen() }
		)
		return ExposureSubmissionIntroViewController(viewModel)
	}

	// MARK: - Internal

	/// - NOTE: We keep a weak reference here to avoid a reference cycle.
	///  (the navigationController holds a strong reference to the coordinator).
	weak var navigationController: UINavigationController?

	// MARK: - Private

	private weak var parentNavigationController: UINavigationController?
	private weak var presentedViewController: UIViewController?

	private var model: ExposureSubmissionCoordinatorModel!
	private let warnOthersReminder: WarnOthersRemindable
	
	private func push(_ vc: UIViewController) {
		self.navigationController?.pushViewController(vc, animated: true)
	}

	private var subscriptions = [AnyCancellable]()

	// MARK: Initial Screens

	private func createTestResultAvailableViewController(testResult: TestResult) -> UIViewController {
		let viewModel = TestResultAvailableViewModel(
			exposureSubmissionService: model.exposureSubmissionService,
			onSubmissionConsentCellTap: { [weak self] isLoading in
				self?.model.exposureSubmissionService.loadSupportedCountries(
					isLoading: isLoading,
					onSuccess: { supportedCountries in
						self?.showTestResultSubmissionConsentScreen(
							supportedCountries: supportedCountries,
							testResultAvailability: .availableAndPositive
						)
					}
				)
			},
			onPrimaryButtonTap: { [weak self] isLoading in
				guard let self = self else { return }

				guard self.model.exposureSubmissionService.isSubmissionConsentGiven else {
					self.showTestResultScreen(with: testResult)
					return
				}

				isLoading(true)
				self.model.exposureSubmissionService.getTemporaryExposureKeys { error in
					isLoading(false)
					
					guard let error = error else {
						self.showTestResultScreen(with: testResult)
						return
					}
					
					// User selected "Don't Share" / "Nicht teilen"
					if error == .notAuthorized {
						Log.info("OS submission authorization was declined.")
						self.model.exposureSubmissionService.isSubmissionConsentGiven = false
						self.showTestResultScreen(with: testResult)
					} else {
						self.showErrorAlert(for: error)
					}
				}
			},
			onDismiss: { [weak self] in
				self?.showTestResultAvailableCloseAlert()
			}
		)
		return TestResultAvailableViewController(viewModel)
	}
	
	private func createTestResultViewController(with testResult: TestResult) -> ExposureSubmissionTestResultViewController {
		updateStoreWithKeySubmissionDefaultValues()
		updateStoreWithLastSubmissionFlow(screen: .submissionFlowScreenTestResult)

		let testResultAvailability: TestResultAvailability = testResult == .positive ? .availableAndPositive : .notAvailabile
		return ExposureSubmissionTestResultViewController(
			viewModel: .init(
				testResult: testResult,
				exposureSubmissionService: model.exposureSubmissionService,
				warnOthersReminder: warnOthersReminder,
				onSubmissionConsentCellTap: { [weak self] isLoading in
					self?.model.exposureSubmissionService.loadSupportedCountries(
						isLoading: isLoading,
						onSuccess: { supportedCountries in
							self?.showTestResultSubmissionConsentScreen(
								supportedCountries: supportedCountries,
								testResultAvailability: testResultAvailability
							)
						}
					)
				},
				onContinueWithSymptomsFlowButtonTap: { [weak self] in
					self?.showSymptomsScreen()
				},
				onContinueWarnOthersButtonTap: { [weak self] isLoading in
					Log.debug("\(#function) will load app config", log: .appConfig)
					self?.model.exposureSubmissionService.loadSupportedCountries(
						isLoading: isLoading,
						onSuccess: { supportedCountries in
							Log.debug("\(#function) did load app config", log: .appConfig)
							self?.showWarnOthersScreen(supportedCountries: supportedCountries)
						}
					)
				},
				onChangeToPositiveTestResult: { [weak self] in
					self?.showTestResultAvailableScreen(with: .positive)
				},
				onTestDeleted: { [weak self] in
					self?.dismiss()
				}
			),
			exposureSubmissionService: self.model.exposureSubmissionService,
			onDismiss: { [weak self] testResult, isLoading in
				if testResult == TestResult.positive {
					self?.showPositiveTestResultCancelAlert(isLoading: isLoading)
				} else {
					self?.dismiss()
				}
				
			}
		)
	}

	private func createWarnOthersViewController() -> ExposureSubmissionWarnOthersViewController {
		updateStoreWithLastSubmissionFlow(screen: .submissionFlowScreenWarnOthers)

		// ugly but works for the moment
		// refactoring more of the coordinator-logic to facilitate combine would help
		let vc = ExposureSubmissionWarnOthersViewController(
			viewModel: ExposureSubmissionWarnOthersViewModel(
				supportedCountries: model.exposureSubmissionService.supportedCountries) { [weak self] in
				self?.showTestResultAvailableCloseAlert()
			},
			onPrimaryButtonTap: { [weak self] isLoading in
				self?.model.exposureSubmissionService.isSubmissionConsentGiven = true
				self?.model.exposureSubmissionService.getTemporaryExposureKeys { error in
					isLoading(false)
					guard let error = error else {
						self?.showThankYouScreen()
						return
					}
					self?.model.exposureSubmissionService.isSubmissionConsentGiven = false
					if error == .notAuthorized {
						Log.info("Submission consent reset to false after OS authorization was not given.")
					} else {
						self?.showErrorAlert(for: error)
					}
				}
			}
		)
		return vc
	}

	// MARK: Screen Flow

	private func showHotlineScreen() {
		let vc = ExposureSubmissionHotlineViewController(
			onSecondaryButtonTap: { [weak self] in
				self?.showTanScreen()
			}
		)

		push(vc)
	}

	private func presentTanInvalidAlert(localizedDescription: String, completion: @escaping () -> Void) {
		let alert = UIAlertController(title: AppStrings.ExposureSubmission.generalErrorTitle, message: localizedDescription, preferredStyle: .alert)
		alert.addAction(
			UIAlertAction(
				title: AppStrings.Common.alertActionOk,
				style: .cancel,
				handler: { _ in
					completion()
				})
		)
		navigationController?.present(alert, animated: true)

	}

	private func showQRInfoScreen(supportedCountries: [Country]) {
		let vc = ExposureSubmissionQRInfoViewController(
			supportedCountries: supportedCountries,
			onPrimaryButtonTap: { [weak self] isLoading in
				self?.model.exposureSubmissionService.acceptPairing()
				self?.model.exposureSubmissionService.isSubmissionConsentGiven = true
				if #available(iOS 14.4, *) {
					self?.exposureManager.preAuthorizeKeys(completion: { error in
						DispatchQueue.main.async { [weak self] in
							if let error = error as? ENError {
								switch error.toExposureSubmissionError() {
								case .notAuthorized:
									// user did not authorize -> continue to scanning the qr code
									self?.showQRScreen(isLoading: isLoading)
								default:
									// present alert
									let alert = UIAlertController.errorAlert(message: error.localizedDescription, completion: { [weak self] in
										self?.showQRScreen(isLoading: isLoading)
									})
									self?.navigationController?.present(alert, animated: true, completion: nil)
								}
							} else {
								// continue to scanning the qr code
								self?.showQRScreen(isLoading: isLoading)
							}
						}
					})
				} else {
					self?.showQRScreen(isLoading: isLoading)
				}
			}
		)

		push(vc)
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
				case .other:
					Log.error("QRScannerError.other occurred.", log: .ui)
				}
			},
			onCancel: { [weak self] in
				self?.model.exposureSubmissionService.isSubmissionConsentGiven = false
				self?.presentedViewController?.dismiss(animated: true)
			}
		)

		let qrScannerNavigationController = UINavigationController(rootViewController: scannerViewController)
		qrScannerNavigationController.modalPresentationStyle = .fullScreen

		navigationController?.present(qrScannerNavigationController, animated: true)
		presentedViewController = qrScannerNavigationController
	}

	private func showTestResultAvailableScreen(with testResult: TestResult) {
		let vc = createTestResultAvailableViewController(testResult: testResult)
		push(vc)
	}

	private func showTestResultSubmissionConsentScreen(supportedCountries: [Country], testResultAvailability: TestResultAvailability) {
		// we should show the alert in the completion only if the testResult is positveAndAvailable
		let dismissCompletion: (() -> Void)? = testResultAvailability == .notAvailabile ? nil : { [weak self] in
			self?.showTestResultAvailableCloseAlert()
		}
		let vc = ExposureSubmissionTestResultConsentViewController(
			viewModel: ExposureSubmissionTestResultConsentViewModel(
				supportedCountries: supportedCountries,
				exposureSubmissionService: model.exposureSubmissionService,
				testResultAvailability: testResultAvailability,
				dismissCompletion: dismissCompletion
			)
		)

		push(vc)
	}

	// MARK: Late consent

	private func showWarnOthersScreen(supportedCountries: [Country]) {
		let viewModel = ExposureSubmissionWarnOthersViewModel(supportedCountries: supportedCountries) { [weak self] in
			self?.showTestResultAvailableCloseAlert()
		}
		let vc = ExposureSubmissionWarnOthersViewController(
			viewModel: viewModel,
			onPrimaryButtonTap: { [weak self] isLoading in
				self?.model.exposureSubmissionService.isSubmissionConsentGiven = true
				self?.model.exposureSubmissionService.getTemporaryExposureKeys { error in
					isLoading(false)
					
					guard let error = error else {
						self?.showThankYouScreen()
						return
					}
					
					self?.model.exposureSubmissionService.isSubmissionConsentGiven = false
					
					// User selected "Don't Share" / "Nicht teilen"
					if error == .notAuthorized {
						Log.info("OS submission authorization was declined.")
					} else {
						Log.error("\(#function) error", log: .ui, error: error)
						self?.showErrorAlert(for: error)
					}
				}
			}
		)

		push(vc)
	}

	private func showThankYouScreen() {
		let thankYouVC = ExposureSubmissionThankYouViewController(
			onPrimaryButtonTap: { [weak self] in
				self?.showSymptomsScreen()
			},
			onDismiss: { [weak self] isLoading in
				self?.showThankYouCancelAlert(isLoading: isLoading)
			}
		)

		push(thankYouVC)
	}

	// MARK: Symptoms

	private func showSymptomsScreen() {
		updateStoreWithLastSubmissionFlow(screen: .submissionFlowScreenSymptoms)
		
		let vc = ExposureSubmissionSymptomsViewController(
			onPrimaryButtonTap: { [weak self] selectedSymptomsOption, isLoading in
				guard let self = self else { return }
				
				self.model.symptomsOptionSelected(selectedSymptomsOption)
				// we don't need to set it true if yes is selected
				if selectedSymptomsOption != .yes {
					self.updateStoreWithSubmissionAfterSymptomFlow(value: true)
				}
				self.model.shouldShowSymptomsOnsetScreen ? self.showSymptomsOnsetScreen() : self.submitExposureAndDismiss(isLoading: isLoading)
			},
			onDismiss: { [weak self] isLoading in
				self?.showSubmissionSymptomsCancelAlert(isLoading: isLoading)
			}
		)

		push(vc)
	}

	private func showSymptomsOnsetScreen() {
		updateStoreWithLastSubmissionFlow(screen: .submissionFlowScreenSymptomOnset)
		
		let vc = ExposureSubmissionSymptomsOnsetViewController(
			onPrimaryButtonTap: { [weak self] selectedSymptomsOnsetOption, isLoading in
				self?.model.symptomsOnsetOptionSelected(selectedSymptomsOnsetOption)
				// setting it to true regardless of the options selected
				self?.updateStoreWithSubmissionAfterSymptomFlow(value: true)
				self?.submitExposureAndDismiss(isLoading: isLoading)
			},
			onDismiss: { [weak self] isLoading in
				self?.showSubmissionSymptomsCancelAlert(isLoading: isLoading)
			}
		)

		push(vc)
	}

	// MARK: Cancel Alerts

	private func showTestResultAvailableCloseAlert() {
		let isSubmissionConsentGiven = self.model.exposureSubmissionService.isSubmissionConsentGiven

		let alertTitle = isSubmissionConsentGiven ? AppStrings.ExposureSubmissionTestResultAvailable.closeAlertTitle : AppStrings.ExposureSubmissionTestResultAvailable.noConsentCloseAlertTitle

		let alertMessage = isSubmissionConsentGiven ? AppStrings.ExposureSubmissionTestResultAvailable.closeAlertMessage : AppStrings.ExposureSubmissionTestResultAvailable.noConsentCloseAlertMessage

		let alert = UIAlertController(
			title: alertTitle,
			message: alertMessage,
			preferredStyle: .alert
		)

		alert.addAction(
			UIAlertAction(
				title: AppStrings.ExposureSubmissionTestResultAvailable.closeAlertButtonClose,
				style: .cancel,
				handler: { [weak self] _ in
					self?.dismiss()
				}
			)
		)

		alert.addAction(
			UIAlertAction(
				title: AppStrings.ExposureSubmissionTestResultAvailable.closeAlertButtonContinue,
				style: .default
			)
		)

		navigationController?.present(alert, animated: true, completion: nil)
	}

	private func showPositiveTestResultCancelAlert(isLoading: @escaping (Bool) -> Void) {
		let isSubmissionConsentGiven = self.model.exposureSubmissionService.isSubmissionConsentGiven

		let alertTitle = isSubmissionConsentGiven ? AppStrings.ExposureSubmissionSymptomsCancelAlert.title : AppStrings.ExposureSubmissionPositiveTestResult.noConsentAlertTitle
		let alertMessage = isSubmissionConsentGiven ? AppStrings.ExposureSubmissionSymptomsCancelAlert.message : AppStrings.ExposureSubmissionPositiveTestResult.noConsentAlertDescription

		let cancelAlertButtonTitle = isSubmissionConsentGiven ? AppStrings.ExposureSubmissionSymptomsCancelAlert.cancelButton :
			AppStrings.ExposureSubmissionPositiveTestResult.noConsentAlertButtonDontWarn

		let continueAlertButtonTitle = isSubmissionConsentGiven ? AppStrings.ExposureSubmissionSymptomsCancelAlert.continueButton :
			AppStrings.ExposureSubmissionPositiveTestResult.noConsentAlertButtonWarn

		let alert = UIAlertController(
			title: alertTitle,
			message: alertMessage,
			preferredStyle: .alert)

		let statyOnScreenAction = UIAlertAction(
			title: cancelAlertButtonTitle,
			style: .default,
			handler: { [weak self] _ in
				if isSubmissionConsentGiven {
					self?.updateStoreWithSubmissionAfterCancellation(value: true)
					self?.submitExposureAndDismiss(isLoading: isLoading)
				} else {
					self?.dismiss()
				}
			}
		)
		// DEFAULT action, although this is labelled as 'cancelAlertButtonTitle'!
		statyOnScreenAction.accessibilityIdentifier = AccessibilityIdentifiers.General.defaultButton
		alert.addAction(statyOnScreenAction)

		let leaveScreenAction = UIAlertAction(
			title: continueAlertButtonTitle,
			style: .cancel
		)
		// CANCEL action, although this is labelled as 'continueAlertButtonTitle'!
		leaveScreenAction.accessibilityIdentifier = AccessibilityIdentifiers.General.cancelButton
		alert.addAction(leaveScreenAction)

		navigationController?.present(alert, animated: true, completion: {
			#if DEBUG
			// see: https://stackoverflow.com/a/40688141/194585
			let stayButton = statyOnScreenAction.value(forKey: "__representer")
			let leaveButton = leaveScreenAction.value(forKey: "__representer")

			let stayView = stayButton as? UIView
			stayView?.accessibilityIdentifier = AccessibilityIdentifiers.General.defaultButton

			let leaveView = leaveButton as? UIView
			leaveView?.accessibilityIdentifier = AccessibilityIdentifiers.General.cancelButton
			#endif
		})
	}
	
	private func showThankYouCancelAlert(isLoading: @escaping (Bool) -> Void) {
		let alertTitle = AppStrings.ExposureSubmissionSymptomsCancelAlert.title
		let alertMessage = AppStrings.ExposureSubmissionSymptomsCancelAlert.message
		let cancelAlertButtonTitle = AppStrings.ExposureSubmissionSymptomsCancelAlert.cancelButton
		let continueAlertButtonTitle = AppStrings.ExposureSubmissionSymptomsCancelAlert.continueButton
		
		let alert = UIAlertController(
			title: alertTitle,
			message: alertMessage,
			preferredStyle: .alert
		)
		
		alert.addAction(
			UIAlertAction(
				title: cancelAlertButtonTitle,
				style: .cancel,
				handler: { [weak self] _ in
					self?.updateStoreWithSubmissionAfterCancellation(value: true)
					self?.submitExposureAndDismiss(isLoading: isLoading)
				}
			)
		)
		
		alert.addAction(
			UIAlertAction(
				title: continueAlertButtonTitle,
				style: .default
			)
		)

		navigationController?.present(alert, animated: true, completion: nil)
	}

	private func showSubmissionSymptomsCancelAlert(isLoading: @escaping (Bool) -> Void) {
		let alert = UIAlertController(
			title: AppStrings.ExposureSubmissionSymptomsCancelAlert.title,
			message: AppStrings.ExposureSubmissionSymptomsCancelAlert.message,
			preferredStyle: .alert
		)

		alert.addAction(
			UIAlertAction(
				title: AppStrings.ExposureSubmissionSymptomsCancelAlert.cancelButton,
				style: .cancel,
				handler: { [weak self] _ in
					self?.updateStoreWithSubmissionAfterCancellation(value: true)
					self?.submitExposureAndDismiss(isLoading: isLoading)
				}
			)
		)

		alert.addAction(
			UIAlertAction(
				title: AppStrings.ExposureSubmissionSymptomsCancelAlert.continueButton,
				style: .default
			)
		)

		navigationController?.present(alert, animated: true, completion: nil)
	}
	
	private func showErrorAlert(for error: ExposureSubmissionError, onCompletion: (() -> Void)? = nil) {
		Log.error("error: \(error.localizedDescription)", log: .ui)

		let alert = UIAlertController.errorAlert(
			message: error.localizedDescription,
			secondaryActionTitle: error.faqURL != nil ? AppStrings.Common.errorAlertActionMoreInfo : nil,
			completion: onCompletion,
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

		navigationController?.present(alert, animated: true)
	}
	
	// MARK: Key Submission Service
	
	private func updateStoreWithLastSubmissionFlow(screen: LastSubmissionFlowScreen) {
		let keySubmissionService = KeySubmissionService(store: self.store)
		keySubmissionService.setLastSubmissionFlowScreen(withValue: .submissionFlowScreenSymptomOnset)
	}
	
	private func updateStoreWithSubmissionAfterSymptomFlow(value: Bool) {
		let keySubmissionService = KeySubmissionService(store: self.store)
		keySubmissionService.setSubmittedAfterSymptomFlow(withValue: true)
	}
	
	private func updateStoreWithSubmissionAfterCancellation(value: Bool) {
		let keySubmissionService = KeySubmissionService(store: self.store)
		keySubmissionService.setSubmittedAfterCancel(withValue: true)
	}
	
	private func updateStoreWithKeySubmissionDefaultValues() {
		self.store.keySubmissionMetadata = KeySubmissionMetadata(submitted: false, submittedInBackground: false, submittedAfterCancel: false, submittedAfterSymptomFlow: false, lastSubmissionFlowScreen: .submissionFlowScreenUnknown, advancedConsentGiven: self.store.isSubmissionConsentGiven, hoursSinceTestResult: 0, hoursSinceTestRegistration: 0, daysSinceMostRecentDateAtRiskLevelAtTestRegistration: 0, hoursSinceHighRiskWarningAtTestRegistration: 0, submittedWithTeleTAN: true)
	}

	// MARK: Test Result Helper

	private func getTestResults(for key: DeviceRegistrationKey, isLoading: @escaping (Bool) -> Void) {
		model.getTestResults(
			for: key,
			isLoading: isLoading,
			onSuccess: { [weak self] testResult in
				switch testResult {
				case .positive:
					self?.showTestResultAvailableScreen(with: testResult)
				case .pending, .negative, .invalid, .expired:
					self?.showTestResultScreen(with: testResult)
				}
			},
			onError: { [weak self] error in
				let alert: UIAlertController

				switch error {
				case .qrDoesNotExist:
					alert = UIAlertController.errorAlert(
						title: AppStrings.ExposureSubmissionError.qrNotExistTitle,
						message: error.localizedDescription
					)
				case .qrAlreadyUsed:
					alert = UIAlertController.errorAlert(
						title: AppStrings.ExposureSubmissionError.qrAlreadyUsedTitle,
						message: error.localizedDescription,
						okTitle: AppStrings.Common.alertActionCancel,
						secondaryActionTitle: AppStrings.Common.alertActionRetry,
						completion: { [weak self] in
							self?.navigationController?.dismiss(animated: true)
						},
						secondaryActionCompletion: { [weak self] in
							self?.showQRScreen(isLoading: isLoading)
						}
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

	private func submitExposureAndDismiss(isLoading: @escaping (Bool) -> Void) {
		self.model.submitExposure(
			isLoading: isLoading,
			onSuccess: { [weak self] in
				self?.dismiss()
			},
			onError: { [weak self] error in
				// reset all the values taken during the submission flow
				self?.updateStoreWithSubmissionAfterSymptomFlow(value: false)
				self?.updateStoreWithSubmissionAfterCancellation(value: false)
				self?.updateStoreWithLastSubmissionFlow(screen: .submissionFlowScreenUnknown)
				self?.showErrorAlert(for: error) {
					self?.dismiss()
				}
			}
		)
	}

}

extension ExposureSubmissionCoordinator: UIAdaptivePresentationControllerDelegate {

	func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
		dismiss()
	}
}
