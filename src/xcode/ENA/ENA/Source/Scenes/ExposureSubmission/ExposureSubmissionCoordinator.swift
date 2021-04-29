//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine
import ExposureNotification

// swiftlint:disable file_length
/// Concrete implementation of the ExposureSubmissionCoordinator protocol.
// swiftlint:disable:next type_body_length
class ExposureSubmissionCoordinator: NSObject, RequiresAppDependencies {

	// MARK: - Init

	init(
		parentNavigationController: UINavigationController,
		exposureSubmissionService: ExposureSubmissionService,
		coronaTestService: CoronaTestService,
		eventProvider: EventProviding,
		antigenTestProfileStore: AntigenTestProfileStoring
	) {
		self.parentNavigationController = parentNavigationController
		self.antigenTestProfileStore = antigenTestProfileStore

		super.init()

		model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: coronaTestService,
			eventProvider: eventProvider
		)
	}

	// MARK: - Internal

	func start(with coronaTestType: CoronaTestType? = nil) {
		model.coronaTestType = coronaTestType

		start(with: self.getInitialViewController())
	}

	func start(with testInformationResult: Result<CoronaTestQRCodeInformation, QRCodeError>) {
		model.exposureSubmissionService.loadSupportedCountries(
			isLoading: { _ in },
			onSuccess: { supportedCountries in
				switch testInformationResult {
				case let .success(testInformation):
					let qrInfoScreen = self.makeQRInfoScreen(supportedCountries: supportedCountries, testInformation: testInformation)
					self.start(with: qrInfoScreen)
				case let .failure(qrCodeError):
					switch qrCodeError {
					case .invalidTestCode:
						self.showRATInvalidQQCode()
					}
				}
			}
		)
	}

	private func showRATInvalidQQCode() {
		let alert = UIAlertController(
			title: AppStrings.ExposureSubmission.ratQRCodeInvalidAlertTitle,
			message: AppStrings.ExposureSubmission.ratQRCodeInvalidAlertText,
			preferredStyle: .alert)
		alert.addAction(
			UIAlertAction(
				title: AppStrings.ExposureSubmission.ratQRCodeInvalidAlertButton,
				style: .default
			)
		)
		parentNavigationController?.present(alert, animated: true)
	}

	func dismiss(completion: (() -> Void)? = nil) {
		navigationController?.dismiss(animated: true, completion: {
			// used for updating (hiding) app shortcuts
			QuickAction.exposureSubmissionFlowTestResult = nil
			completion?()
		})
	}

	func showTestResultScreen() {
		let vc = createTestResultViewController()
		push(vc)

		// If a TAN was entered, we skip `showTestResultAvailableScreen(with:)`, so we notify (again) about the new state
		QuickAction.exposureSubmissionFlowTestResult = model.coronaTest?.testResult
	}

	func showTanScreen() {
		let tanInputViewModel = TanInputViewModel(
			coronaTestService: model.coronaTestService,
			presentInvalidTanAlert: { [weak self] localizedDescription, completion  in
				self?.presentTanInvalidAlert(localizedDescription: localizedDescription, completion: completion)
			},
			tanSuccessfullyTransferred: { [weak self] in
				self?.model.coronaTestType = .pcr

				// A TAN always indicates a positive test result.
				self?.showTestResultScreen()
			}
		)

		let vc = TanInputViewController(
			viewModel: tanInputViewModel,
			dismiss: { [weak self] in self?.dismiss() }
		)
		
		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.ExposureSubmissionTanEntry.submit,
			primaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.primaryButton,
			isPrimaryButtonEnabled: false,
			isSecondaryButtonHidden: true
		)

		let footerViewController = FooterViewController(footerViewModel)
		let topBottomViewController = TopBottomContainerViewController(topController: vc, bottomController: footerViewController)
		
		push(topBottomViewController)
	}

	/// This method selects the correct initial view controller among the following options:
	/// Option 1: (only for UITESTING) if the `-negativeResult` flag was passed, return ExposureSubmissionTestResultViewController
	/// Option 2: if a test result was passed, the method checks further preconditions (e.g. the exposure submission service has a registration token)
	/// and returns an ExposureSubmissionTestResultViewController.
	/// Option 3: (default) return the ExposureSubmissionIntroViewController.
	func getInitialViewController() -> UIViewController {
		// We got a test result and can jump straight into the test result view controller.
		if let coronaTest = model.coronaTest {
			// For a positive test result we show the test result available screen if it wasn't shown before
			if coronaTest.testResult == .positive && !coronaTest.keysSubmitted {
				if !coronaTest.positiveTestResultWasShown {
					return createTestResultAvailableViewController()
				} else {
					return createWarnOthersViewController(supportedCountries: model.exposureSubmissionService.supportedCountries)
				}
			} else {
				return createTestResultViewController()
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
			onHotlineButtonTap: { [weak self] in self?.showHotlineScreen() },
			onRapidTestProfileTap: { [weak self] in
				// later move that to the title and inject both methods - just to get flow working
				if self?.store.antigenTestProfile == nil {
					self?.showCreateAntigenTestProfile()
				} else {
					self?.showAntigenTestProfile()
				}
			},
			antigenTestProfileStore: antigenTestProfileStore
		)
		return ExposureSubmissionIntroViewController(
			viewModel: viewModel,
			dismiss: { [weak self] in
				self?.dismiss()
			}
		)
	}

	/// - NOTE: We keep a weak reference here to avoid a reference cycle.
	///  (the navigationController holds a strong reference to the coordinator).
	weak var navigationController: UINavigationController?

	// MARK: - Private

	private weak var parentNavigationController: UINavigationController?
	private weak var presentedViewController: UIViewController?

	private var model: ExposureSubmissionCoordinatorModel!
	private let antigenTestProfileStore: AntigenTestProfileStoring

	private func push(_ vc: UIViewController) {
		self.navigationController?.pushViewController(vc, animated: true)
	}

	private var subscriptions = [AnyCancellable]()

	// MARK: Start

	private func start(with initialViewController: UIViewController) {
		guard let parentNavigationController = parentNavigationController else {
			Log.error("Parent navigation controller not set.", log: .ui)
			return
		}

		/// The navigation controller keeps a strong reference to the coordinator. The coordinator only reaches reference count 0
		/// when UIKit dismisses the navigationController.
		let exposureSubmissionNavigationController = ExposureSubmissionNavigationController(
			coordinator: self,
			dismissClosure: { [weak self] in
				self?.dismiss()
			},
			rootViewController: initialViewController
		)
		parentNavigationController.present(exposureSubmissionNavigationController, animated: true)
		navigationController = exposureSubmissionNavigationController
	}

	// MARK: Initial Screens

	private func createTestResultAvailableViewController() -> UIViewController {
        guard let coronaTestType = model.coronaTestType, let coronaTest = model.coronaTest else {
			fatalError("Cannot create a test result available view controller without a corona test")
		}

		QuickAction.exposureSubmissionFlowTestResult = coronaTest.testResult

		let viewModel = TestResultAvailableViewModel(
			coronaTestType: coronaTestType,
			coronaTestService: model.coronaTestService,
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
				guard let self = self, let coronaTest = self.model.coronaTest else { return }

				guard coronaTest.isSubmissionConsentGiven else {
					self.showTestResultScreen()
					return
				}

				isLoading(true)
				self.model.exposureSubmissionService.getTemporaryExposureKeys { error in
					isLoading(false)

					guard let error = error else {
						self.showCheckinsScreen()
						return
					}

					// User selected "Don't Share" / "Nicht teilen"
					if error == .notAuthorized {
						Log.info("OS submission authorization was declined.")
						self.model.setSubmissionConsentGiven(false)
						self.showTestResultScreen()
					} else {
						self.showErrorAlert(for: error)
					}
				}
			},
			onDismiss: { [weak self] in
				self?.showTestResultAvailableCloseAlert()
			}
		)
		
		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.ExposureSubmissionTestResultAvailable.primaryButtonTitle,
			isSecondaryButtonEnabled: false,
			isSecondaryButtonHidden: true
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: TestResultAvailableViewController(viewModel),
			bottomController: FooterViewController(footerViewModel)
		)
		
		return topBottomContainerViewController
	}

	private func createTestResultViewController() -> TopBottomContainerViewController<ExposureSubmissionTestResultViewController, FooterViewController> {
		guard let coronaTestType = model.coronaTestType, let coronaTest = model.coronaTest else {
			fatalError("Could not find corona test to create test result view controller for.")
		}

		// store is only initialized when a positive test result is received and not yet submitted
		if coronaTest.testResult == .positive && !coronaTest.keysSubmitted {
            updateStoreWithKeySubmissionMetadataDefaultValues(for: coronaTest)
			QuickAction.exposureSubmissionFlowTestResult = coronaTest.testResult
		}
		Analytics.collect(.keySubmissionMetadata(.lastSubmissionFlowScreen(.submissionFlowScreenTestResult)))

		let testResultAvailability: TestResultAvailability = model.coronaTest?.testResult == .positive ? .availableAndPositive : .notAvailable
		
		let viewModel = ExposureSubmissionTestResultViewModel(
			coronaTestType: coronaTestType,
			coronaTestService: model.coronaTestService,
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
				self?.showTestResultAvailableScreen()
			},
			onTestDeleted: { [weak self] in
				self?.dismiss()
			}
		)
		
		let vc = ExposureSubmissionTestResultViewController(
			viewModel: viewModel,
			exposureSubmissionService: self.model.exposureSubmissionService,
			onDismiss: { [weak self] testResult, isLoading in
				if testResult == TestResult.positive && !coronaTest.keysSubmitted {
					self?.showPositiveTestResultCancelAlert(isLoading: isLoading)
				} else {
					self?.dismiss()
				}
			}
		)
		
		let footerViewController = FooterViewController(
			ExposureSubmissionTestResultViewModel.footerViewModel(coronaTest: coronaTest)
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: vc,
			bottomController: footerViewController
		)
		
		return topBottomContainerViewController
	}

	private func createWarnOthersViewController(supportedCountries: [Country]) -> UIViewController {
		Analytics.collect(.keySubmissionMetadata(.lastSubmissionFlowScreen(.submissionFlowScreenWarnOthers)))

		let vc = ExposureSubmissionWarnOthersViewController(
			viewModel: ExposureSubmissionWarnOthersViewModel(
				supportedCountries: supportedCountries
			) { [weak self] in
				self?.showTestResultAvailableCloseAlert()
			},
			onPrimaryButtonTap: { [weak self] isLoading in
				self?.model.setSubmissionConsentGiven(true)
				self?.model.exposureSubmissionService.getTemporaryExposureKeys { error in
					isLoading(false)
					guard let error = error else {
						self?.showCheckinsScreen()
						return
					}
					self?.model.setSubmissionConsentGiven(false)
					if error == .notAuthorized {
						Log.info("Submission consent reset to false after OS authorization was not given.")
					} else {
						self?.showErrorAlert(for: error)
					}
				}
			},
			dismiss: { [weak self] in self?.dismiss() }
		)
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.ExposureSubmissionQRInfo.primaryButtonTitle,
				primaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.primaryButton,
				secondaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.secondaryButton,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true
			)
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: vc,
			bottomController: footerViewController
		)
		
		return topBottomContainerViewController
	}

	// MARK: Screen Flow

	private func showHotlineScreen() {
		let vc = ExposureSubmissionHotlineViewController(
			onSecondaryButtonTap: { [weak self] in
				self?.showTanScreen()
			},
			dismiss: { [weak self] in self?.dismiss() }
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

	private func makeQRInfoScreen(supportedCountries: [Country], testInformation: CoronaTestQRCodeInformation?) -> UIViewController {
		let vc = ExposureSubmissionQRInfoViewController(
			supportedCountries: supportedCountries,
			onPrimaryButtonTap: { [weak self] isLoading in
				if #available(iOS 14.4, *) {
					self?.exposureManager.preAuthorizeKeys(completion: { error in
						DispatchQueue.main.async { [weak self] in
							if let error = error as? ENError {
								switch error.toExposureSubmissionError() {
								case .notAuthorized:
									// user did not authorize -> continue to scanning the qr code
									self?.showQRScreen(testInformation: testInformation, isLoading: isLoading)
								default:
									// present alert
									let alert = UIAlertController.errorAlert(message: error.localizedDescription, completion: { [weak self] in
										self?.showQRScreen(testInformation: testInformation, isLoading: isLoading)
									})
									self?.navigationController?.present(alert, animated: true, completion: nil)
								}
							} else {
								// continue to scanning the qr code
								self?.showQRScreen(testInformation: testInformation, isLoading: isLoading)
							}
						}
					})
				} else {
					self?.showQRScreen(testInformation: testInformation, isLoading: isLoading)
				}
			},
			dismiss: { [weak self] in self?.dismiss() }
		)

		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.ExposureSubmissionQRInfo.primaryButtonTitle,
				primaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.primaryButton,
				secondaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.secondaryButton,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true
			)
		)

		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: vc,
			bottomController: footerViewController
		)

		return topBottomContainerViewController
	}

	private func showQRInfoScreen(supportedCountries: [Country]) {
		push(makeQRInfoScreen(supportedCountries: supportedCountries, testInformation: nil))
	}

	private func showQRScreen(testInformation: CoronaTestQRCodeInformation?, isLoading: @escaping (Bool) -> Void) {
		let testInformationSuccess: (CoronaTestQRCodeInformation) -> Void = { [weak self] testQRCodeInformation in
			if let oldTest = self?.model.coronaTestService.coronaTest(ofType: testQRCodeInformation.testType),
			   oldTest.testResult != .expired && oldTest.testResult != .invalid {
				self?.showOverrideTestNotice(testQRCodeInformation: testQRCodeInformation, submissionConsentGiven: true)
			} else {
				self?.registerTestAndGetResult(with: testQRCodeInformation, submissionConsentGiven: true, isLoading: isLoading)
			}
		}

		if let testInformation = testInformation {
			testInformationSuccess(testInformation)
		} else {
			let scannerViewController = ExposureSubmissionQRScannerViewController(
				onSuccess: { [weak self] testQRCodeInformation in
					DispatchQueue.main.async {
						self?.presentedViewController?.dismiss(animated: true) {
							testInformationSuccess(testQRCodeInformation)
						}
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
					self?.presentedViewController?.dismiss(animated: true)
				}
			)

			let qrScannerNavigationController = UINavigationController(rootViewController: scannerViewController)
			qrScannerNavigationController.modalPresentationStyle = .fullScreen

			navigationController?.present(qrScannerNavigationController, animated: true)
			presentedViewController = qrScannerNavigationController
		}

	}

	private func showTestResultAvailableScreen() {
		let vc = createTestResultAvailableViewController()
		push(vc)

		// used for updating (hiding) app shortcuts
		QuickAction.exposureSubmissionFlowTestResult = model.coronaTest?.testResult
	}

	private func showTestResultSubmissionConsentScreen(supportedCountries: [Country], testResultAvailability: TestResultAvailability) {
		guard let coronaTestType = model.coronaTestType else {
			fatalError("Could not find corona test type to show the consent screen for.")
		}

		// we should show the alert in the completion only if the testResult is positiveAndAvailable
		let dismissCompletion: (() -> Void)? = testResultAvailability == .notAvailable ? nil : { [weak self] in
			self?.showTestResultAvailableCloseAlert()
		}
		let vc = ExposureSubmissionTestResultConsentViewController(
			viewModel: ExposureSubmissionTestResultConsentViewModel(
				supportedCountries: supportedCountries,
				coronaTestType: coronaTestType,
				coronaTestService: model.coronaTestService,
				testResultAvailability: testResultAvailability,
				dismissCompletion: dismissCompletion
			)
		)

		push(vc)
	}
	
	private func showCheckinsScreen() {
		let showNextScreen = { [weak self] in
			if self?.model.coronaTest?.positiveTestResultWasShown == true {
				self?.showThankYouScreen()
			} else {
				self?.showTestResultScreen()
			}
		}
		
		guard model.eventProvider.checkinsPublisher.value.contains(where: { $0.checkinCompleted }) else {
			showNextScreen()
			return
		}

		/// Reset checkins when entering the screen in case the user skips, cancels or stays on the screen during background submission
		model.exposureSubmissionService.checkins = []
		
		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.ExposureSubmissionCheckins.continueButton,
			secondaryButtonName: AppStrings.ExposureSubmissionCheckins.skipButton,
			isPrimaryButtonEnabled: false,
			backgroundColor: .enaColor(for: .darkBackground)
		)

		let checkinsVC = ExposureSubmissionCheckinsViewController(
			checkins: model.eventProvider.checkinsPublisher.value,
			onCompletion: { [weak self] selectedCheckins in
				self?.model.exposureSubmissionService.checkins = selectedCheckins
				showNextScreen()
			},
			onSkip: { [weak self] in
				self?.showSkipCheckinsAlert(dontShareHandler: {
					showNextScreen()
				})
			},
			onDismiss: { [weak self] in
				if self?.model.coronaTest?.positiveTestResultWasShown == true {
					self?.showSkipCheckinsAlert(dontShareHandler: {
						Analytics.collect(.keySubmissionMetadata(.submittedAfterCancel(true)))
						self?.submitExposure(showSubmissionSuccess: false) { isLoading in
							footerViewModel.setLoadingIndicator(isLoading, disable: isLoading, button: .secondary)
							footerViewModel.setLoadingIndicator(false, disable: isLoading, button: .primary)
						}
					})
				} else {
					self?.showTestResultAvailableCloseAlert()
				}
			}
		)
		
		let footerVC = FooterViewController(footerViewModel)
		
		let topBottomVC = TopBottomContainerViewController(topController: checkinsVC, bottomController: footerVC)
		
		push(topBottomVC)
	}

	// MARK: Late consent

	private func showWarnOthersScreen(supportedCountries: [Country]) {
		let vc = createWarnOthersViewController(supportedCountries: supportedCountries)
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
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.ThankYouScreen.continueButton,
				secondaryButtonName: AppStrings.ThankYouScreen.cancelButton,
				primaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.primaryButton,
				secondaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.secondaryButton,
				isPrimaryButtonEnabled: true,
				isSecondaryButtonEnabled: true
			)
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: thankYouVC,
			bottomController: footerViewController
		)

		push(topBottomContainerViewController)
	}

	// MARK: Symptoms

	private func showSymptomsScreen() {
		Analytics.collect(.keySubmissionMetadata(.lastSubmissionFlowScreen(.submissionFlowScreenSymptoms)))

		let vc = ExposureSubmissionSymptomsViewController(
			onPrimaryButtonTap: { [weak self] selectedSymptomsOption, isLoading in
				guard let self = self else { return }

				self.model.symptomsOptionSelected(selectedSymptomsOption)
				// we don't need to set it true if yes is selected
				if selectedSymptomsOption != .yes {
					Analytics.collect(.keySubmissionMetadata(.submittedAfterSymptomFlow(true)))
				}
				self.model.shouldShowSymptomsOnsetScreen ? self.showSymptomsOnsetScreen() : self.submitExposure(showSubmissionSuccess: true, isLoading: isLoading)
			},
			onDismiss: { [weak self] isLoading in
				self?.showSubmissionSymptomsCancelAlert(isLoading: isLoading)
			}
		)

		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.ExposureSubmissionSymptoms.continueButton,
				primaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.primaryButton,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true
			)
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: vc,
			bottomController: footerViewController
		)

		push(topBottomContainerViewController)
	}

	private func showSymptomsOnsetScreen() {
		Analytics.collect(.keySubmissionMetadata(.lastSubmissionFlowScreen(.submissionFlowScreenSymptomOnset)))

		let vc = ExposureSubmissionSymptomsOnsetViewController(
			onPrimaryButtonTap: { [weak self] selectedSymptomsOnsetOption, isLoading in
				self?.model.symptomsOnsetOptionSelected(selectedSymptomsOnsetOption)
				// setting it to true regardless of the options selected
				Analytics.collect(.keySubmissionMetadata(.submittedAfterSymptomFlow(true)))
				self?.submitExposure(showSubmissionSuccess: true, isLoading: isLoading)
			},
			onDismiss: { [weak self] isLoading in
				self?.showSubmissionSymptomsCancelAlert(isLoading: isLoading)
			}
		)

		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.ExposureSubmissionSymptomsOnset.continueButton,
				primaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.primaryButton,
				isPrimaryButtonEnabled: true,
				isSecondaryButtonEnabled: false,
				isPrimaryButtonHidden: false,
				isSecondaryButtonHidden: true
			)
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: vc,
			bottomController: footerViewController
		)

		push(topBottomContainerViewController)
	}

	// MARK: - AntigenTestProfile

	private func showAntigenTestProfileInformation() {
		var antigenTestProfileInformationViewController: AntigenTestProfileInformationViewController!
		antigenTestProfileInformationViewController = AntigenTestProfileInformationViewController(
			store: store,
			didTapDataPrivacy: {
				// please check if we really wanna use it that way
				if case let .execute(block) = DynamicAction.push(htmlModel: AppInformationModel.privacyModel, withTitle: AppStrings.AppInformation.privacyTitle) {
					block(antigenTestProfileInformationViewController, nil)
				}
			},
			didTapContinue: { [weak self] in
				self?.showCreateAntigenTestProfile()
			},
			dismiss: { [weak self] in self?.dismiss() }
		)

		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.ExposureSubmission.AntigenTest.Information.primaryButton,
			isPrimaryButtonEnabled: true,
			isSecondaryButtonEnabled: false,
			isSecondaryButtonHidden: true
		)
		let footerViewController = FooterViewController(footerViewModel)
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: antigenTestProfileInformationViewController,
			bottomController: footerViewController
		)

		push(topBottomContainerViewController)
	}

	private func showCreateAntigenTestProfile() {
		guard store.antigenTestProfileInfoScreenShown else {
			showAntigenTestProfileInformation()
			return
		}

		let createAntigenTestProfileViewController = CreateAntigenTestProfileViewController(
			store: store,
			didTapSave: { [weak self] in
				self?.showAntigenTestProfile()
			},
			dismiss: { [weak self] in self?.dismiss() }
		)

		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.AntigenProfile.Create.saveButtonTitle,
			isPrimaryButtonEnabled: false,
			isSecondaryButtonEnabled: false,
			isSecondaryButtonHidden: true
		)
		let footerViewController = FooterViewController(footerViewModel)
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: createAntigenTestProfileViewController,
			bottomController: footerViewController
		)

		push(topBottomContainerViewController)
	}

	private func showAntigenTestProfile() {
		let antigenTestProfileViewController = AntigenTestProfileViewController(
			store: store,
			didTapContinue: { [weak self] isLoading in
				self?.model.coronaTestType = .antigen
				self?.model.exposureSubmissionService.loadSupportedCountries(
					isLoading: isLoading,
					onSuccess: { supportedCountries in
						self?.showQRInfoScreen(supportedCountries: supportedCountries)
					}
				)

			},
			didTapDeleteProfile: { [weak self] in
				self?.navigationController?.popViewController(animated: true)
			}, dismiss: { [weak self] in self?.dismiss() }
		)

		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.ExposureSubmission.AntigenTest.Profile.primaryButton,
			secondaryButtonName: AppStrings.ExposureSubmission.AntigenTest.Profile.secondaryButton,
			isPrimaryButtonEnabled: true,
			isSecondaryButtonEnabled: true,
			secondaryButtonInverted: true,
			backgroundColor: .enaColor(for: .cellBackground)
		)
		let footerViewController = FooterViewController(footerViewModel)
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: antigenTestProfileViewController,
			bottomController: footerViewController
		)

		push(topBottomContainerViewController)
	}

	// MARK: Cancel Alerts

	private func showTestResultAvailableCloseAlert() {

		let alert = UIAlertController(
			title: AppStrings.ExposureSubmissionTestResultAvailable.closeAlertTitle,
			message: nil,
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
		guard let coronaTest = model.coronaTest else { return }

		let isSubmissionConsentGiven = coronaTest.isSubmissionConsentGiven

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

		let stayOnScreenAction = UIAlertAction(
			title: cancelAlertButtonTitle,
			style: .default,
			handler: { [weak self] _ in
				if isSubmissionConsentGiven {
					Analytics.collect(.keySubmissionMetadata(.submittedAfterCancel(true)))
					self?.submitExposure(showSubmissionSuccess: false, isLoading: isLoading)
				} else {
					self?.dismiss()
				}
			}
		)
		// DEFAULT action, although this is labelled as 'cancelAlertButtonTitle'!
		stayOnScreenAction.accessibilityIdentifier = AccessibilityIdentifiers.General.defaultButton
		alert.addAction(stayOnScreenAction)

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
			let stayButton = stayOnScreenAction.value(forKey: "__representer")
			let leaveButton = leaveScreenAction.value(forKey: "__representer")

			let stayView = stayButton as? UIView
			stayView?.accessibilityIdentifier = AccessibilityIdentifiers.General.defaultButton

			let leaveView = leaveButton as? UIView
			leaveView?.accessibilityIdentifier = AccessibilityIdentifiers.General.cancelButton
			#endif
		})
	}
	
	private func showSkipCheckinsAlert(dontShareHandler: @escaping () -> Void) {
		let alert = UIAlertController(
			title: AppStrings.ExposureSubmissionCheckins.alertTitle,
			message: AppStrings.ExposureSubmissionCheckins.alertMessage,
			preferredStyle: .alert
		)

		alert.addAction(
			UIAlertAction(
				title: AppStrings.ExposureSubmissionCheckins.alertDontShare,
				style: .cancel,
				handler: { _ in
					dontShareHandler()
				}
			)
		)

		alert.addAction(
			UIAlertAction(
				title: AppStrings.ExposureSubmissionCheckins.alertShare,
				style: .default
			)
		)

		navigationController?.present(alert, animated: true, completion: nil)
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
					Analytics.collect(.keySubmissionMetadata(.submittedAfterCancel(true)))
					self?.submitExposure(showSubmissionSuccess: false, isLoading: isLoading)
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
					Analytics.collect(.keySubmissionMetadata(.submittedAfterCancel(true)))
					self?.submitExposure(showSubmissionSuccess: false, isLoading: isLoading)
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

	private func updateStoreWithKeySubmissionMetadataDefaultValues(for coronaTest: CoronaTest) {
		let keySubmissionMetadata = KeySubmissionMetadata(
			submitted: false,
			submittedInBackground: false,
			submittedAfterCancel: false,
			submittedAfterSymptomFlow: false,
			lastSubmissionFlowScreen: .submissionFlowScreenUnknown,
			advancedConsentGiven: coronaTest.isSubmissionConsentGiven,
			hoursSinceTestResult: 0,
			hoursSinceTestRegistration: 0,
			daysSinceMostRecentDateAtRiskLevelAtTestRegistration: -1,
			hoursSinceHighRiskWarningAtTestRegistration: -1)
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata)))
		Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtRiskLevelAtTestRegistration))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceHighRiskWarningAtTestRegistration))
	}

	// MARK: Test Result Helper

	// show a overwrite notice screen if a test of give type was registered before
	// registerTestAndGetResult will update the loading state of the primary button
	private func showOverrideTestNotice(
		testQRCodeInformation: CoronaTestQRCodeInformation,
		submissionConsentGiven: Bool
	) {

		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.ExposureSubmission.OverwriteNotice.primaryButton,
			isSecondaryButtonHidden: true
		)

		let overwriteNoticeViewController = TestOverwriteNoticeViewController(
			testType: testQRCodeInformation.testType,
			didTapPrimaryButton: { [weak self] in
				self?.registerTestAndGetResult(with: testQRCodeInformation, submissionConsentGiven: submissionConsentGiven, isLoading: { isLoading in
					footerViewModel.setLoadingIndicator(isLoading, disable: isLoading, button: .primary)
				})
			},
			didTapCloseButton: { [weak self] in
				// on cancel the submission flow is stopped immediately
				self?.parentNavigationController?.dismiss(animated: true)
			}
		)

		let footerViewController = FooterViewController(footerViewModel)
		let topBottomViewController = TopBottomContainerViewController(topController: overwriteNoticeViewController, bottomController: footerViewController)
		topBottomViewController.navigationItem.hidesBackButton = true
		push(topBottomViewController)
	}

	private func registerTestAndGetResult(
		with testQRCodeInformation: CoronaTestQRCodeInformation,
		submissionConsentGiven: Bool,
		isLoading: @escaping (Bool) -> Void
	) {
		model.registerTestAndGetResult(
			for: testQRCodeInformation,
			isSubmissionConsentGiven: submissionConsentGiven,
			isLoading: isLoading,
			onSuccess: { [weak self] testResult in
				
				self?.model.coronaTestType = testQRCodeInformation.testType

				switch testResult {
				case .positive:
					self?.showTestResultAvailableScreen()
				case .pending, .negative, .invalid, .expired:
					self?.showTestResultScreen()
				}
			},
			onError: { [weak self] error in
				let alert: UIAlertController

				switch error {
				case .responseFailure(.qrDoesNotExist):
					alert = UIAlertController.errorAlert(
						title: AppStrings.ExposureSubmissionError.qrNotExistTitle,
						message: error.localizedDescription
					)
				case .responseFailure(.qrAlreadyUsed):
					alert = UIAlertController.errorAlert(
						title: AppStrings.ExposureSubmissionError.qrAlreadyUsedTitle,
						message: error.localizedDescription,
						okTitle: AppStrings.Common.alertActionCancel,
						secondaryActionTitle: AppStrings.Common.alertActionRetry,
						completion: { [weak self] in
							self?.dismiss()
						},
						secondaryActionCompletion: { [weak self] in
							self?.showQRScreen(testInformation: nil, isLoading: isLoading)
						}
					)
				case .testExpired:
					alert = UIAlertController.errorAlert(
						title: AppStrings.ExposureSubmission.qrCodeExpiredTitle,
						message: error.localizedDescription
					)
				default:
					alert = UIAlertController.errorAlert(
						message: error.localizedDescription,
						secondaryActionTitle: AppStrings.Common.alertActionRetry,
						secondaryActionCompletion: {
							self?.registerTestAndGetResult(
								with: testQRCodeInformation,
								submissionConsentGiven: submissionConsentGiven,
								isLoading: isLoading
							)
						}
					)
				}

				self?.navigationController?.present(alert, animated: true, completion: nil)

				Log.error("An error occurred during result fetching: \(error)", log: .ui)
			}
		)
	}
	
	private func submitExposure(showSubmissionSuccess: Bool = false, isLoading: @escaping (Bool) -> Void) {
		self.model.submitExposure(
			isLoading: isLoading,
			onSuccess: { [weak self] in
				if showSubmissionSuccess {
					self?.showExposureSubmissionSuccessViewController()
				} else {
					self?.dismiss()
				}
			},
			onError: { [weak self] error in
				// reset all the values taken during the submission flow because submission failed
				Analytics.collect(.keySubmissionMetadata(.submittedAfterSymptomFlow(false)))
				Analytics.collect(.keySubmissionMetadata(.submittedAfterCancel(false)))
				Analytics.collect(.keySubmissionMetadata(.lastSubmissionFlowScreen(.submissionFlowScreenUnknown)))
				self?.showErrorAlert(for: error) {
					self?.dismiss()
				}
			}
		)
	}
	
	private func showExposureSubmissionSuccessViewController() {
		guard let coronaTestType = model.coronaTestType else {
			Log.error("No corona test type set to show the success view controller for, dismissing to be safe", log: .ui)
			dismiss()
			return
		}

		let exposureSubmissionSuccessViewController = ExposureSubmissionSuccessViewController(
			coronaTestType: coronaTestType,
			dismiss: { [weak self] in
				self?.dismiss()
			}
		)
		
		push(exposureSubmissionSuccessViewController)
	}
}

extension ExposureSubmissionCoordinator: UIAdaptivePresentationControllerDelegate {

	func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
		dismiss()
	}
}
