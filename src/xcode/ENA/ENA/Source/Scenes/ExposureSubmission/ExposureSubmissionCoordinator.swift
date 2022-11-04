//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine
import ExposureNotification
import PDFKit

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class ExposureSubmissionCoordinator: NSObject, RequiresAppDependencies {

	// MARK: - Init

	init(
		parentViewController: UIViewController,
		exposureSubmissionService: ExposureSubmissionService,
		coronaTestService: CoronaTestServiceProviding,
		familyMemberCoronaTestService: FamilyMemberCoronaTestServiceProviding,
		healthCertificateService: HealthCertificateService,
		healthCertificateValidationService: HealthCertificateValidationProviding,
		eventProvider: EventProviding,
		antigenTestProfileStore: AntigenTestProfileStoring,
		vaccinationValueSetsProvider: VaccinationValueSetsProviding,
		healthCertificateValidationOnboardedCountriesProvider: HealthCertificateValidationOnboardedCountriesProviding,
		qrScannerCoordinator: QRScannerCoordinator,
		recycleBin: RecycleBin
	) {
		self.parentViewController = parentViewController
		self.healthCertificateService = healthCertificateService
		self.healthCertificateValidationService = healthCertificateValidationService
		self.antigenTestProfileStore = antigenTestProfileStore
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider
		self.healthCertificateValidationOnboardedCountriesProvider = healthCertificateValidationOnboardedCountriesProvider
		self.qrScannerCoordinator = qrScannerCoordinator

		super.init()

		model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			eventProvider: eventProvider,
			recycleBin: recycleBin
		)
	}

	// MARK: - Internal

	func start(with coronaTestType: CoronaTestType? = nil) {
		model.coronaTestType = coronaTestType

		start(with: self.getInitialViewController())
	}

	func start(with testRegistrationInformationResult: Result<CoronaTestRegistrationInformation, QRCodeError>, markNewlyAddedCoronaTestAsUnseen: Bool = false) {
		model.markNewlyAddedCoronaTestAsUnseen = markNewlyAddedCoronaTestAsUnseen

		if case .success(let testRegistrationInformation) = testRegistrationInformationResult,
		   let recycleBinItemToRestore = model.recycleBinItemToRestore(for: testRegistrationInformation) {
			showTestRestoredFromBinAlert(recycleBinItem: recycleBinItemToRestore)
			return
		}

		model.exposureSubmissionService.loadSupportedCountries(
			isLoading: { _ in },
			onSuccess: { supportedCountries in
				switch testRegistrationInformationResult {
				case let .success(testRegistrationInformation):
					self.start(
						with: self.createTestOwnerSelectionScreen(
							supportedCountries: supportedCountries,
							testRegistrationInformation: testRegistrationInformation
						)
					)
				case let .failure(qrCodeError):
					switch qrCodeError {
					case .invalidTestCode:
						self.showRATInvalidQRCode()
					}
				}
			}
		)
	}

	func dismiss(completion: (() -> Void)? = nil) {
		navigationController?.dismiss(animated: true, completion: {
			// used for updating (hiding) app shortcuts
			QuickAction.exposureSubmissionFlowTestResult = nil
			completion?()
		})
	}

	func showTestResultScreen(triggeredFromTeletan: Bool = false) {
		let vc = createTestResultViewController(triggeredFromTeletan: triggeredFromTeletan)
		push(vc)

		// If a TAN was entered, we skip `showTestResultAvailableScreen(with:)`, so we notify (again) about the new state
		QuickAction.exposureSubmissionFlowTestResult = model.coronaTest?.testResult
	}

	func showTanScreen() {
		let tanInputViewModel = TanInputViewModel(
			title: AppStrings.ExposureSubmissionTanEntry.title,
			description: AppStrings.ExposureSubmissionTanEntry.description,
			onPrimaryButtonTap: { [weak self] tan, isLoading in
				self?.showOverrideTestNoticeIfNecessary(
					testRegistrationInformation: .teleTAN(tan: tan),
					submissionConsentGiven: false,
					isLoading: isLoading
				)
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
				#warning("Remove, only for DEV")
				self?.showTypeOfTestsScreen()
//				self?.showQRScreen(testRegistrationInformation: nil, isLoading: isLoading)
			},
			onFindTestCentersTap: {
				LinkHelper.open(urlString: AppStrings.Links.findTestCentersFAQ)
			},
			onTANButtonTap: { [weak self] in self?.showTanScreen() },
			onHotlineButtonTap: { [weak self] in self?.showHotlineScreen() },
			onRapidTestProfileTap: { [weak self] in
				guard let antigenTestProfileInfoScreenShown = self?.store.antigenTestProfileInfoScreenShown, antigenTestProfileInfoScreenShown else {
					self?.showAntigenTestProfileInformation()
					return
				}
				self?.showAntigenTestProfileOverview()
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

	private weak var parentViewController: UIViewController?

	private var model: ExposureSubmissionCoordinatorModel!
	private let antigenTestProfileStore: AntigenTestProfileStoring
	private let vaccinationValueSetsProvider: VaccinationValueSetsProviding
	private let healthCertificateValidationOnboardedCountriesProvider: HealthCertificateValidationOnboardedCountriesProviding
	private let qrScannerCoordinator: QRScannerCoordinator

	private let healthCertificateService: HealthCertificateService
	private let healthCertificateValidationService: HealthCertificateValidationProviding
	private var certificateCoordinator: HealthCertificateCoordinator?

	private var antigenTestProfileOverviewViewController: AntigenTestProfileOverviewViewController?
	
	private func push(_ vc: UIViewController) {
		navigationController?.topViewController?.view.endEditing(true)
		navigationController?.pushViewController(vc, animated: true)
	}
	
	private func present(_ vc: UIViewController, withNavigation: Bool = true) {
		let navVC = NavigationControllerWithLargeTitle(rootViewController: vc)
		navigationController?.topViewController?.view.endEditing(true)
		navigationController?.present(navVC, animated: true)
	}

	private func popViewController() {
		self.navigationController?.popViewController(animated: true)
	}

	// MARK: Start

	private func start(with initialViewController: UIViewController) {
		guard let parentViewController = parentViewController else {
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
		parentViewController.present(exposureSubmissionNavigationController, animated: true)
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
			primaryIdentifier: AccessibilityIdentifiers.ExposureSubmissionTestResultAvailable.primaryButton,
			isSecondaryButtonEnabled: false,
			isSecondaryButtonHidden: true
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: TestResultAvailableViewController(viewModel),
			bottomController: FooterViewController(footerViewModel)
		)
		
		return topBottomContainerViewController
	}

	private func createTestResultViewController(triggeredFromTeletan: Bool = false) -> TopBottomContainerViewController<ExposureSubmissionTestResultViewController, FooterViewController> {
		guard let coronaTestType = model.coronaTestType, let coronaTest = model.coronaTest else {
			fatalError("Could not find corona test to create test result view controller for.")
		}

		if coronaTest.testResult == .positive && !coronaTest.keysSubmitted {
			QuickAction.exposureSubmissionFlowTestResult = coronaTest.testResult
		}
		Analytics.collect(.keySubmissionMetadata(.lastSubmissionFlowScreen(.submissionFlowScreenTestResult, coronaTestType)))

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
			},
			onTestCertificateCellTap: { [weak self] healthCertificate, healthCertifiedPerson in
				self?.showHealthCertificateFlow(healthCertifiedPerson: healthCertifiedPerson, healthCertificate: healthCertificate)
			}
		)
		
		let vc = ExposureSubmissionTestResultViewController(
			viewModel: viewModel,
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
		if let testType = model.coronaTestType {
			Analytics.collect(.keySubmissionMetadata(.lastSubmissionFlowScreen(.submissionFlowScreenWarnOthers, testType)))
		}

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

	private func createTestOwnerSelectionScreen(
		supportedCountries: [Country],
		testRegistrationInformation: CoronaTestRegistrationInformation,
		temporaryAntigenTestProfileName: String? = nil
	) -> ExposureSubmissionTestOwnerSelectionViewController {
		return ExposureSubmissionTestOwnerSelectionViewController(
			viewModel: ExposureSubmissionTestOwnerSelectionViewModel(
				onTestOwnerSelection: { [weak self] testOwner in
					switch testOwner {
					case .user:
						self?.showQRInfoScreen(
							supportedCountries: supportedCountries,
							testRegistrationInformation: testRegistrationInformation
						)
					case .familyMember:
						self?.showFamilyMemberTestConsentScreen(
							testRegistrationInformation: testRegistrationInformation,
							temporaryAntigenTestProfileName: temporaryAntigenTestProfileName
						)
					}
				}
			),
			onDismiss: { [weak self] in
				self?.dismiss()
			}
		)
	}

	// MARK: Screen Flow

	private func showHotlineScreen() {
		let vc = ExposureSubmissionHotlineViewController(
			onPrimaryButtonTap: { [weak self] in
				self?.showTanScreen()
			},
			dismiss: { [weak self] in self?.dismiss() }
		)

		push(vc)
	}

	private func makeQRInfoScreen(supportedCountries: [Country], testRegistrationInformation: CoronaTestRegistrationInformation) -> UIViewController {
		let vc = ExposureSubmissionQRInfoViewController(
			supportedCountries: supportedCountries,
			onPrimaryButtonTap: { [weak self] isLoading in
				if #available(iOS 14.4, *) {
					Log.info("Start preauthorizaton for keys...")

					self?.exposureManager.preAuthorizeKeys(completion: { error in
						DispatchQueue.main.async { [weak self] in
							if let error = error as? ENError {
								let submissionError = error.toExposureSubmissionError()
								Log.error("Preauthorizaton for keys failed with ENError: \(error.localizedDescription), ExposureSubmissionError: \(submissionError.localizedDescription)")

								switch submissionError {
								case .notAuthorized:
									self?.showOverrideTestNoticeIfNecessary(
										testRegistrationInformation: testRegistrationInformation,
										submissionConsentGiven: true,
										isLoading: isLoading
									)
								default:
									// present alert
									let alert = UIAlertController.errorAlert(message: submissionError.localizedDescription, completion: { [weak self] in
										self?.showOverrideTestNoticeIfNecessary(
											testRegistrationInformation: testRegistrationInformation,
											submissionConsentGiven: true,
											isLoading: isLoading
										)
									})
									self?.navigationController?.present(alert, animated: true, completion: nil)
								}
							} else {
								Log.info("Preauthorizaton for keys was successful.")

								self?.showOverrideTestNoticeIfNecessary(
									testRegistrationInformation: testRegistrationInformation,
									submissionConsentGiven: true,
									isLoading: isLoading
								)
							}
						}
					})
				} else {
					self?.showOverrideTestNoticeIfNecessary(
						testRegistrationInformation: testRegistrationInformation,
						submissionConsentGiven: true,
						isLoading: isLoading
					)
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
	
	private func showQRInfoScreen(supportedCountries: [Country], testRegistrationInformation: CoronaTestRegistrationInformation) {
		push(makeQRInfoScreen(supportedCountries: supportedCountries, testRegistrationInformation: testRegistrationInformation))
	}

	private func showFamilyMemberTestConsentScreen(
		testRegistrationInformation: CoronaTestRegistrationInformation,
		temporaryAntigenTestProfileName: String? = nil
	) {
		let familyMemberConsentViewController = FamilyMemberConsentViewController(
			viewModel: FamilyMemberConsentViewModel(
				temporaryAntigenTestProfileName,
				presentDisclaimer: { [weak self] in
					self?.showDataPrivacy()
				}
			),
			dismiss: { [weak self] in
				self?.dismiss()
			}, didTapDataPrivacy: { [weak self] in
				self?.showDataPrivacy()
			}, didTapSubmit: { [weak self] givenName in
				Log.info("User has give name \(private: givenName)")
				self?.showTestCertificateScreenIfNecessary(
					testOwner: .familyMember(displayName: givenName),
					testRegistrationInformation: testRegistrationInformation,
					submissionConsentGiven: false,
					isLoading: { _ in }
				)
			}
		)

		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.HealthCertificate.FamilyMemberConsent.primaryButton,
				primaryIdentifier: AccessibilityIdentifiers.HealthCertificate.FamilyMemberConsent.primaryButton,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true
			)
		)

		let topBottomLayoutViewController = TopBottomContainerViewController(
			topController: familyMemberConsentViewController,
			bottomController: footerViewController
		)
		push(topBottomLayoutViewController)
	}

	private func showTestResultScreen(for familyMemberCoronaTest: FamilyMemberCoronaTest) {
		let familyMemberTestResultScreen = createTestResultScreen(for: familyMemberCoronaTest)
		push(familyMemberTestResultScreen)
	}
	
	private func createTestResultScreen(for familyMemberCoronaTest: FamilyMemberCoronaTest) -> UIViewController {
		let viewModel = ExposureSubmissionTestResultFamilyMemberViewModel(
			familyMemberCoronaTest: familyMemberCoronaTest,
			familyMemberCoronaTestService: model.familyMemberCoronaTestService,
			keepMarkedAsNew: true,
			onTestDeleted: { [weak self] in
				self?.dismiss()
			},
			onTestCertificateCellTap: { [weak self] healthCertificate, healthCertifiedPerson in
				self?.showHealthCertificateFlow(healthCertifiedPerson: healthCertifiedPerson, healthCertificate: healthCertificate)
			}
		)
		
		let vc = ExposureSubmissionTestResultViewController(
			viewModel: viewModel,
			onDismiss: { [weak self] _, _ in
				self?.dismiss()
			}
		)
		
		let footerViewController = FooterViewController(
			ExposureSubmissionTestResultFamilyMemberViewModel.footerViewModel(coronaTest: familyMemberCoronaTest)
		)
		
		return TopBottomContainerViewController(
			topController: vc,
			bottomController: footerViewController
		)
	}
	
	private func showQRScreen(
		testRegistrationInformation: CoronaTestRegistrationInformation?,
		temporaryAntigenTestProfileName: String? = nil,
		isLoading: @escaping (Bool) -> Void
	) {
		if let testRegistrationInformation = testRegistrationInformation {
			showOverrideTestNoticeIfNecessary(
				testRegistrationInformation: testRegistrationInformation,
				submissionConsentGiven: true,
				isLoading: isLoading
			)
		} else {
			guard let navigationController = navigationController else {
				Log.error("Cannot present QR code scanner without navigation controller in submission flow")
				return
			}

			qrScannerCoordinator.didScanCoronaTestInSubmissionFlow = { [weak self] testRegistrationInformation in
				guard let self = self else {
					return
				}

				DispatchQueue.main.async {
					if let recycleBinItemToRestore = self.model.recycleBinItemToRestore(for: testRegistrationInformation) {
						self.dismiss {
							self.showTestRestoredFromBinAlert(recycleBinItem: recycleBinItemToRestore)
						}

						return
					}

					self.model.exposureSubmissionService.loadSupportedCountries(
						isLoading: isLoading,
						onSuccess: { supportedCountries in
							self.push(
								self.createTestOwnerSelectionScreen(
									supportedCountries: supportedCountries,
									testRegistrationInformation: testRegistrationInformation,
									temporaryAntigenTestProfileName: temporaryAntigenTestProfileName
								)
							)
						}
					)
				}
			}

			qrScannerCoordinator.start(
				parentViewController: navigationController,
				presenter: .submissionFlow
			)
		}

	}

	private func showRATInvalidQRCode() {
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
		parentViewController?.present(alert, animated: true)
	}
	
	// show an overwrite notice screen if a test of given type was registered before
	// registerTestAndGetResult will update the loading state of the primary button later
	private func showOverrideTestNoticeIfNecessary(
		testRegistrationInformation: CoronaTestRegistrationInformation,
		submissionConsentGiven: Bool,
		isLoading: @escaping (Bool) -> Void
	) {
		guard model.shouldShowOverrideTestNotice(for: testRegistrationInformation.testType) else {
			showTestCertificateScreenIfNecessary(
				testOwner: .user,
				testRegistrationInformation: testRegistrationInformation,
				submissionConsentGiven: submissionConsentGiven,
				isLoading: isLoading
			)

			return
		}

		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.ExposureSubmission.OverwriteNotice.primaryButton,
			isSecondaryButtonHidden: true
		)

		let overwriteNoticeViewController = TestOverwriteNoticeViewController(
			testType: testRegistrationInformation.testType,
			didTapPrimaryButton: { [weak self] in
				self?.showTestCertificateScreenIfNecessary(
					testOwner: .user,
					testRegistrationInformation: testRegistrationInformation,
					submissionConsentGiven: submissionConsentGiven,
					isLoading: { isLoading in
						footerViewModel.setLoadingIndicator(isLoading, disable: isLoading, button: .primary)
					}
				)
			},
			didTapCloseButton: { [weak self] in
				// on cancel the submission flow is stopped immediately
				self?.parentViewController?.dismiss(animated: true)
			}
		)

		let footerViewController = FooterViewController(footerViewModel)
		let topBottomViewController = TopBottomContainerViewController(topController: overwriteNoticeViewController, bottomController: footerViewController)
		topBottomViewController.navigationItem.hidesBackButton = true
		push(topBottomViewController)
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
			backgroundColor: .enaColor(for: .background)
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
						if let testType = self?.model.coronaTestType {
							Analytics.collect(.keySubmissionMetadata(.submittedAfterCancel(true, testType)))
						}
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

	private func showHealthCertificateFlow(
		healthCertifiedPerson: HealthCertifiedPerson,
		healthCertificate: HealthCertificate
	) {
		guard let navigationController = navigationController else {
			Log.error("Could not show health certificate flow from exposure submission as navigation controller was nil", log: .vaccination)
			return
		}

		certificateCoordinator = HealthCertificateCoordinator(
			parentingViewController: .push(navigationController),
			healthCertifiedPerson: healthCertifiedPerson,
			healthCertificate: healthCertificate,
			store: store,
			healthCertificateService: healthCertificateService,
			healthCertificateValidationService: healthCertificateValidationService,
			healthCertificateValidationOnboardedCountriesProvider: healthCertificateValidationOnboardedCountriesProvider,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			markAsSeenOnDisappearance: true
		)

		certificateCoordinator?.start()
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
	
	private func showTypeOfTestsScreen() {
		let vc = TypeOfTestViewController { [weak self] submissionType in
			print(submissionType)
		} onDismiss: { [weak self] _ in
			print("Warn-Vorgang abbrechen? Alert")
		}
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: "Weiter",
				primaryIdentifier: "todo",
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true
			)
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: vc,
			bottomController: footerViewController
		)

		present(topBottomContainerViewController)
	}

	private func showSymptomsScreen() {
		if let testType = model.coronaTestType {
			Analytics.collect(.keySubmissionMetadata(.lastSubmissionFlowScreen(.submissionFlowScreenSymptoms, testType)))
		}

		let vc = ExposureSubmissionSymptomsViewController(
			onPrimaryButtonTap: { [weak self] selectedSymptomsOption, isLoading in
				guard let self = self else { return }

				self.model.symptomsOptionSelected(selectedSymptomsOption)
				// we don't need to set it true if yes is selected
				if selectedSymptomsOption != .yes, let testType = self.model.coronaTestType {
					Analytics.collect(.keySubmissionMetadata(.submittedAfterSymptomFlow(true, testType)))
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
		if let testType = self.model.coronaTestType {
			Analytics.collect(.keySubmissionMetadata(.lastSubmissionFlowScreen(.submissionFlowScreenSymptomOnset, testType)))
		}

		let vc = ExposureSubmissionSymptomsOnsetViewController(
			onPrimaryButtonTap: { [weak self] selectedSymptomsOnsetOption, isLoading in
				self?.model.symptomsOnsetOptionSelected(selectedSymptomsOnsetOption)

				if let testType = self?.model.coronaTestType {
					// setting it to true regardless of the options selected
					Analytics.collect(.keySubmissionMetadata(.submittedAfterSymptomFlow(true, testType)))
				}
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
		let viewModel = AntigenTestProfileInformationViewModel(
			store: store,
			showDisclaimer: {
				// please check if we really wanna use it that way
				if case let .execute(block) = DynamicAction.push(htmlModel: AppInformationModel.privacyModel, withTitle: AppStrings.AppInformation.privacyTitle) {
					block(antigenTestProfileInformationViewController, nil)
				}
			}
		)
		antigenTestProfileInformationViewController = AntigenTestProfileInformationViewController(
			viewModel: viewModel,
			didTapContinue: { [weak self] in
				if let antigenTestProfileInfoScreenShown = self?.store.antigenTestProfileInfoScreenShown, antigenTestProfileInfoScreenShown {
					self?.popViewController()
				} else {
					self?.showAntigenTestProfileOverview()
				}
			},
			dismiss: { [weak self] in
				self?.dismiss()
			}
		)

		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.ExposureSubmission.AntigenTest.Information.primaryButton,
			primaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.continueButton,
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

	private func showAntigenTestProfileInput(editMode: Bool, antigenTestProfile: AntigenTestProfile = AntigenTestProfile()) {
		guard store.antigenTestProfileInfoScreenShown || editMode else {
			showAntigenTestProfileInformation()
			return
		}

		let createAntigenTestProfileViewController = AntigenTestProfileInputViewController(
			viewModel: AntigenTestProfileInputViewModel(
				store: store,
				antigenTestProfile: antigenTestProfile
			),
			store: store,
			didTapSave: { [weak self] antigenTestProfile in
				if editMode {
					self?.popViewController()
				} else {
					self?.showAntigenTestProfile(antigenTestProfile: antigenTestProfile)
				}
			},
			dismiss: { [weak self] in self?.dismiss() }
		)

		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.AntigenProfile.Create.saveButtonTitle,
			primaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Create.saveButton,
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

	private func showAntigenTestProfileOverview() {
		let antigenTestProfileOverviewVC = AntigenTestProfileOverviewViewController(
			viewModel: AntigenTestProfileOverviewViewModel(
				store: store,
				onEntryCellTap: { [weak self] antigenTestProfile in
					self?.showAntigenTestProfile(antigenTestProfile: antigenTestProfile)
				}),
			onInfoButtonTap: { [weak self] in
				self?.showAntigenTestProfileInformation()
			},
			onAddEntryCellTap: { [ weak self] in
				self?.showAntigenTestProfileInput(editMode: false)
			},
			onDismiss: { [weak self] in self?.dismiss() }
		)
		
		antigenTestProfileOverviewViewController = antigenTestProfileOverviewVC
		push(antigenTestProfileOverviewVC)
	}
	
	private func showAntigenTestProfile(antigenTestProfile: AntigenTestProfile) {
		let antigenTestProfileViewController = AntigenTestProfileViewController(
			viewModel: AntigenTestProfileViewModel(
				antigenTestProfile: antigenTestProfile,
				store: store
			),
			didTapContinue: { [weak self] isLoading, antigenTestProfile  in
				self?.model.coronaTestType = .antigen
				self?.showQRScreen(
					testRegistrationInformation: nil,
					temporaryAntigenTestProfileName: antigenTestProfile.fullName,
					isLoading: isLoading
				)
			},
			didTapProfileInfo: { [weak self] in
				self?.showAntigenTestProfileInformation()
			},
			didTapEditProfile: { [weak self] antigenTestProfile in
				let viewControllers = [self?.antigenTestProfileOverviewViewController, self?.navigationController?.viewControllers.last].compactMap { $0 }
				self?.navigationController?.setViewControllers(viewControllers, animated: true)
				
				self?.showAntigenTestProfileInput(editMode: true, antigenTestProfile: antigenTestProfile)
			},
			didTapDeleteProfile: { [weak self] in
				guard let antigenTestProfileOverviewViewController = self?.antigenTestProfileOverviewViewController else {
					return
				}
				
				self?.navigationController?.popToViewController(antigenTestProfileOverviewViewController, animated: true)
			}, dismiss: { [weak self] in self?.dismiss() }
		)

		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.ExposureSubmission.AntigenTest.Profile.primaryButton,
			secondaryButtonName: AppStrings.ExposureSubmission.AntigenTest.Profile.secondaryButton,
			primaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.continueButton,
			secondaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.editButton,
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

	// MARK: Test Certificate

	private func showTestCertificateScreenIfNecessary(
		testOwner: TestOwner,
		testRegistrationInformation: CoronaTestRegistrationInformation,
		submissionConsentGiven: Bool,
		isLoading: @escaping (Bool) -> Void
	) {
		guard model.shouldShowTestCertificateScreen(with: testRegistrationInformation) else {
			self.registerTestAndGetResult(
				for: testOwner,
				with: testRegistrationInformation,
				submissionConsentGiven: submissionConsentGiven,
				certificateConsent: .notGiven,
				isLoading: isLoading
			)

			return
		}

		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.ExposureSubmission.TestCertificate.Info.primaryButton,
			secondaryButtonName: AppStrings.ExposureSubmission.TestCertificate.Info.secondaryButton,
			isPrimaryButtonEnabled: true,
			isSecondaryButtonEnabled: true,
			isPrimaryButtonHidden: false,
			isSecondaryButtonHidden: false,
			primaryButtonColor: .enaColor(for: .buttonPrimary),
			secondaryButtonInverted: true,
			backgroundColor: .enaColor(for: .background)
		)

		let testCertificateViewController = ExposureSubmissionTestCertificateViewController(
			ExposureSubmissionTestCertificateViewModel(
				isRapidTest: testRegistrationInformation.isRapidTest,
				presentDisclaimer: { [weak self] in
					self?.showDataPrivacy()
				}
			),
			showCancelAlert: { [weak self] in
				self?.showEndRegistrationAlert(
					submitAction: UIAlertAction(
						title: AppStrings.ExposureSubmission.TestCertificate.Info.Alert.cancelRegistration,
						style: .default,
						handler: { _ in
							self?.navigationController?.dismiss(animated: true)
						}
					)
				)
			},
			didTapPrimaryButton: { [weak self] optionalBirthDateString, isLoading in
				self?.registerTestAndGetResult(
					for: testOwner,
					with: testRegistrationInformation,
					submissionConsentGiven: submissionConsentGiven,
					certificateConsent: .given(dateOfBirth: optionalBirthDateString),
					isLoading: isLoading
				)
			},
			didTapSecondaryButton: { [weak self] isLoading in
				self?.registerTestAndGetResult(
					for: testOwner,
					with: testRegistrationInformation,
					submissionConsentGiven: submissionConsentGiven,
					certificateConsent: .notGiven,
					isLoading: isLoading
				)
			}
		)

		let footerViewController = FooterViewController(footerViewModel)
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: testCertificateViewController,
			bottomController: footerViewController
		)
		push(topBottomContainerViewController)
	}

	private func showDataPrivacy() {
		let detailViewController = HTMLViewController(model: AppInformationModel.privacyModel)
		detailViewController.title = AppStrings.AppInformation.privacyTitle
		detailViewController.isDismissable = false
		if #available(iOS 13.0, *) {
			detailViewController.isModalInPresentation = true
		}
		self.push(detailViewController)
	}

	private func showEndRegistrationAlert(submitAction: UIAlertAction) {
		submitAction.accessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmission.TestCertificate.Alert.cancelRegistration
		let alert = UIAlertController(
			title: AppStrings.ExposureSubmission.TestCertificate.Info.Alert.title,
			message: AppStrings.ExposureSubmission.TestCertificate.Info.Alert.message,
			preferredStyle: .alert
		)
		
		alert.addAction(
			UIAlertAction(
				title: AppStrings.ExposureSubmission.TestCertificate.Info.Alert.continueRegistration,
				style: .cancel,
				handler: nil
			)
		)
		alert.addAction(submitAction)
		navigationController?.present(alert, animated: true)
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
					Analytics.collect(.keySubmissionMetadata(.submittedAfterCancel(true, coronaTest.type)))
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
					if let testType = self?.model.coronaTestType {
						Analytics.collect(.keySubmissionMetadata(.submittedAfterCancel(true, testType)))
					}
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
					if let testType = self?.model.coronaTestType {
						Analytics.collect(.keySubmissionMetadata(.submittedAfterCancel(true, testType)))
					}
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

				LinkHelper.open(url: url)
			}
		)

		navigationController?.present(alert, animated: true)
	}
	
	private func showServiceErrorAlert(for error: ExposureSubmissionServiceError, onCompletion: (() -> Void)? = nil) {
		Log.error("error: \(error.localizedDescription)", log: .ui)

		let alert = UIAlertController.errorAlert(
			message: error.localizedDescription,
			completion: onCompletion
		)

		navigationController?.present(alert, animated: true)
	}

	// MARK: Test Result Helper

	private func alert(
		_ error: CoronaTestServiceError,
		testQRCodeInformation: CoronaTestRegistrationInformation,
		isLoading: @escaping (Bool) -> Void
	) -> UIAlertController? {
		var alert: UIAlertController?
		switch error {
		case .responseFailure(.qrDoesNotExist):
			alert = UIAlertController.errorAlert(
				title: AppStrings.ExposureSubmissionError.qrNotExistTitle,
				message: error.localizedDescription
			)
		case .teleTanError(.receivedResourceError(let teleTanError)):
			switch teleTanError {
			case .qrAlreadyUsed:
				alert = UIAlertController.errorAlert(
					title: AppStrings.ExposureSubmissionError.qrAlreadyUsedTitle,
					message: error.localizedDescription,
					okTitle: AppStrings.Common.alertActionCancel,
					secondaryActionTitle: AppStrings.Common.alertActionRetry,
					completion: { [weak self] in
						self?.dismiss()
					},
					secondaryActionCompletion: { [weak self] in
						self?.showQRScreen(testRegistrationInformation: nil, isLoading: isLoading)
					}
				)
			default:
				// .teleTanAlreadyUsed, .invalidResponse
				break
			}
		case .testExpired:
			alert = UIAlertController.errorAlert(
				title: AppStrings.ExposureSubmission.qrCodeExpiredTitle,
				message: error.localizedDescription,
				completion: { [weak self] in
					self?.dismiss()
				}
			)
		default:
			break
		}

		return alert
	}

	private func registerTestAndGetResult(
		for testOwner: TestOwner,
		with testQRCodeInformation: CoronaTestRegistrationInformation,
		submissionConsentGiven: Bool,
		certificateConsent: TestCertificateConsent,
		isLoading: @escaping (Bool) -> Void
	) {
		func defaultAlert(_ error: Error) -> UIAlertController {
			UIAlertController.errorAlert(
				message: error.localizedDescription,
				secondaryActionTitle: AppStrings.Common.alertActionRetry,
				secondaryActionCompletion: { [weak self] in
					self?.registerTestAndGetResult(
						for: testOwner,
						with: testQRCodeInformation,
						submissionConsentGiven: submissionConsentGiven,
						certificateConsent: certificateConsent,
						isLoading: isLoading
					)
				}
			)
		}
		
		switch testOwner {
		case .user:
			model.registerTestAndGetResult(
				for: testQRCodeInformation,
				isSubmissionConsentGiven: submissionConsentGiven,
				certificateConsent: certificateConsent,
				isLoading: isLoading,
				onSuccess: { [weak self] testResult in
				   self?.model.coronaTestType = testQRCodeInformation.testType
				   
				   switch testQRCodeInformation {
				   case .teleTAN:
					   self?.showTestResultScreen()
				   case .antigen, .pcr, .rapidPCR:
					   switch testResult {
					   case .positive:
						   self?.showTestResultAvailableScreen()
					   case .pending, .negative, .invalid, .expired:
						   self?.showTestResultScreen()
					   }
				   }
				},
				onError: { [weak self] error in
					if error == .testExpired {
						self?.removeExpiredTestAfterRegistration(
							testOwner: .user,
							testQRCodeInformation: testQRCodeInformation
						)
					}

					let alert = self?.alert(error, testQRCodeInformation: testQRCodeInformation, isLoading: isLoading) ?? defaultAlert(error)
					self?.navigationController?.present(alert, animated: true, completion: nil)
					Log.error("An error occurred during result fetching: \(error)", log: .ui)
				}
			)
		case .familyMember(let displayName):
			model.registerFamilyMemberTestAndGetResult(
				for: displayName,
				registrationInformation: testQRCodeInformation,
				certificateConsent: certificateConsent,
				isLoading: isLoading,
				onSuccess: { [weak self] familyMemberCoronaTest in
					self?.showTestResultScreen(for: familyMemberCoronaTest)
				},
				onError: { [weak self] error in
					if error == .testExpired {
						self?.removeExpiredTestAfterRegistration(
							testOwner: .familyMember(displayName: displayName),
							testQRCodeInformation: testQRCodeInformation
						)
					}

					let alert = self?.alert(error, testQRCodeInformation: testQRCodeInformation, isLoading: isLoading) ?? defaultAlert(error)
					self?.navigationController?.present(alert, animated: true, completion: nil)
					Log.error("An error occurred during fetching result for a family member: \(error)", log: .ui)
				}
			)
		}
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
				if let testType = self?.model.coronaTestType {
					// reset all the values taken during the submission flow because submission failed
					Analytics.collect(.keySubmissionMetadata(.submittedAfterSymptomFlow(false, testType)))
					Analytics.collect(.keySubmissionMetadata(.submittedAfterCancel(false, testType)))
					Analytics.collect(.keySubmissionMetadata(.lastSubmissionFlowScreen(.submissionFlowScreenUnknown, testType)))
				}
				self?.showServiceErrorAlert(for: error) {
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

	private func restoreAndStartWithTest(from recycleBinItem: RecycleBinItem) {
		model.recycleBin.restore(recycleBinItem)

		switch recycleBinItem.item {
		case .certificate:
			Log.info("restoreAndShowTest only restores tests")
			return
		case .userCoronaTest(let coronaTest):
			start(with: coronaTest.type)
		case .familyMemberCoronaTest(let coronaTest):
			let familyMemberTestResultViewController = createTestResultScreen(for: coronaTest)
			start(with: familyMemberTestResultViewController)
		}
	}

	private func showTestRestoredFromBinAlert(
		recycleBinItem: RecycleBinItem
	) {
		let alert = UIAlertController(
			title: AppStrings.UniversalQRScanner.testRestoredFromBinAlertTitle,
			message: AppStrings.UniversalQRScanner.testRestoredFromBinAlertMessage,
			preferredStyle: .alert
		)
		alert.addAction(
			UIAlertAction(
				title: AppStrings.Common.alertActionOk,
				style: .default,
				handler: { _ in
					switch self.model.recycleBin.canRestore(recycleBinItem) {
					case .success:
						self.restoreAndStartWithTest(from: recycleBinItem)
					case .failure(.testError(.testTypeAlreadyRegistered)):
						self.showTestOverwriteNotice(recycleBinItem: recycleBinItem)
					}
				}
			)
		)

		parentViewController?.present(alert, animated: true)
	}

	private func showTestOverwriteNotice(
		recycleBinItem: RecycleBinItem
	) {
		guard case let .userCoronaTest(coronaTest) = recycleBinItem.item else {
			return
		}

		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.ExposureSubmission.OverwriteNotice.primaryButton,
			isSecondaryButtonHidden: true
		)

		let overwriteNoticeViewController = TestOverwriteNoticeViewController(
			testType: coronaTest.type,
			didTapPrimaryButton: {
				// Dismiss override notice
				self.parentViewController?.dismiss(animated: true) {
					self.restoreAndStartWithTest(from: recycleBinItem)
				}
			},
			didTapCloseButton: {
				self.parentViewController?.dismiss(animated: true)
			}
		)

		let footerViewController = FooterViewController(footerViewModel)
		let topBottomViewController = TopBottomContainerViewController(
			topController: overwriteNoticeViewController,
			bottomController: footerViewController
		)

		let navigationController = NavigationControllerWithLargeTitle(rootViewController: topBottomViewController)
		parentViewController?.present(navigationController, animated: true)
	}

	private func removeExpiredTestAfterRegistration(
		testOwner: TestOwner,
		testQRCodeInformation: CoronaTestRegistrationInformation
	) {
		// We don't want to save expired tests after registering them
		switch testOwner {
		case .user:
			switch testQRCodeInformation.testType {
			case .antigen:
				model.coronaTestService.antigenTest.value = nil
			case .pcr:
				model.coronaTestService.pcrTest.value = nil
			}
		case .familyMember:
			let qrCodeHash: String = {
				switch testQRCodeInformation {
				case let .pcr(_, qrCodeHash):
					return qrCodeHash
				case let .rapidPCR(_, qrCodeHash):
					return qrCodeHash
				case let .antigen(_, qrCodeHash):
					return qrCodeHash
				case .teleTAN:
					// There should be never this case so we return a string which will never match to any registered family test
					return "No Teletan qrCode"
				}
			}()
			guard let index = model.familyMemberCoronaTestService.coronaTests.value.firstIndex(where: { $0.qrCodeHash == qrCodeHash }) else {
				return
			}
			model.familyMemberCoronaTestService.coronaTests.value.remove(at: index)
		}
	}
}

extension ExposureSubmissionCoordinator: UIAdaptivePresentationControllerDelegate {

	func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
		dismiss()
	}
}
