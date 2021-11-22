//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

// swiftlint:disable file_length
enum QRScannerPresenter: Equatable {
	case submissionFlow
	case onBehalfFlow
	case checkinTab
	case certificateTab
	case universalScanner(SelectedTab?)
}

enum SelectedTab: Equatable {
	case home
	case checkin
	case certificates
	case diary
}

// swiftlint:disable type_body_length
class QRScannerCoordinator {
	
	// MARK: - Init
	
	init(
		store: Store,
		client: Client,
		eventStore: EventStoringProviding,
		appConfiguration: AppConfigurationProviding,
		eventCheckoutService: EventCheckoutService,
		healthCertificateService: HealthCertificateService,
		healthCertificateValidationService: HealthCertificateValidationProviding,
		healthCertificateValidationOnboardedCountriesProvider: HealthCertificateValidationOnboardedCountriesProviding,
		vaccinationValueSetsProvider: VaccinationValueSetsProviding,
		exposureSubmissionService: ExposureSubmissionService,
		coronaTestService: CoronaTestService,
		recycleBin: RecycleBin
	) {
		self.store = store
		self.client = client
		self.eventStore = eventStore
		self.appConfiguration = appConfiguration
		self.eventCheckoutService = eventCheckoutService
		self.healthCertificateService = healthCertificateService
		self.healthCertificateValidationService = healthCertificateValidationService
		self.healthCertificateValidationOnboardedCountriesProvider = healthCertificateValidationOnboardedCountriesProvider
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider
		self.exposureSubmissionService = exposureSubmissionService
		self.coronaTestService = coronaTestService
		self.recycleBin = recycleBin
	}
	
	// MARK: - Internal

	var didScanCoronaTestInSubmissionFlow: ((CoronaTestRegistrationInformation) -> Void)?
	var didScanTraceLocationInOnBehalfFlow: ((TraceLocation) -> Void)?
	
	func start(
		parentViewController: UIViewController,
		presenter: QRScannerPresenter
	) {
		self.parentViewController = parentViewController
		self.presenter = presenter

		let qrScannerViewController = qrScannerViewController(
			markCertificateAsNew: presenter != .certificateTab && presenter != .universalScanner(.certificates)
		)
		self.qrScannerViewController = qrScannerViewController

		let navigationController = UINavigationController(
			rootViewController: qrScannerViewController
		)
		self.parentViewController?.present(navigationController, animated: true)
	}

	// MARK: - Private
	
	private let store: Store
	private let client: Client
	private let eventStore: EventStoringProviding
	private let appConfiguration: AppConfigurationProviding
	private let eventCheckoutService: EventCheckoutService
	private let healthCertificateService: HealthCertificateService
	private let healthCertificateValidationService: HealthCertificateValidationProviding
	private let healthCertificateValidationOnboardedCountriesProvider: HealthCertificateValidationOnboardedCountriesProviding
	private let vaccinationValueSetsProvider: VaccinationValueSetsProviding
	private let exposureSubmissionService: ExposureSubmissionService
	private let coronaTestService: CoronaTestService
	private let recycleBin: RecycleBin

	private let activityIndicatorView = QRScannerActivityIndicatorView()
	private let activityIndicatorAnimationDuration = 0.45
	
	private var presenter: QRScannerPresenter!
	private weak var parentViewController: UIViewController?
	private weak var qrScannerViewController: UIViewController?
	private var healthCertificateCoordinator: HealthCertificateCoordinator?
	private var traceLocationCheckinCoordinator: TraceLocationCheckinCoordinator?
	private var onBehalfCheckinCoordinator: OnBehalfCheckinSubmissionCoordinator?
	private var ticketValidationCoordinator: TicketValidationCoordinator?
	private var fileScannerCoordinator: FileScannerCoordinator?

	private func qrScannerViewController(
		markCertificateAsNew: Bool
	) -> UIViewController {
		let qrCodeParser = QRCodeParser(
			appConfigurationProvider: appConfiguration,
			healthCertificateService: healthCertificateService,
			markCertificateAsNew: markCertificateAsNew
		)

		let qrCodeDetector = QRCodeDetector()

		var qrScannerViewController: QRScannerViewController!
		qrScannerViewController = QRScannerViewController(
			healthCertificateService: healthCertificateService,
			appConfiguration: appConfiguration,
			markCertificateAsNew: markCertificateAsNew,
			didScan: { [weak self] qrCodeResult in
				self?.showQRCodeResult(qrCodeResult: qrCodeResult)
			},
			dismiss: { [weak self] in
				self?.parentViewController?.dismiss(animated: true)
			},
			presentFileScanner: { [weak self] in
				let viewModel = FileScannerCoordinatorViewModel(
					qrCodeDetector: qrCodeDetector,
					qrCodeParser: qrCodeParser
				)
				self?.fileScannerCoordinator = FileScannerCoordinator(
					qrScannerViewController,
					viewModel: viewModel,
					qrCodeFound: { [weak self] qrCodeResult in
						self?.showQRCodeResult(qrCodeResult: qrCodeResult)
						self?.fileScannerCoordinator = nil
					},
					noQRCodeFound: {
						self?.fileScannerCoordinator = nil
					},
					showActivityIndicator: {
						self?.showActivityIndicator()
					},
					hideActivityIndicator: {
						self?.hideActivityIndicator()
					}
				)
				self?.fileScannerCoordinator?.start()
			}
		)
		return qrScannerViewController
	}

	private func showQRCodeResult(qrCodeResult: QRCodeResult) {
		switch qrCodeResult {
		case let .coronaTest(testRegistrationInformation):
			showScannedTestResult(testRegistrationInformation)
		case let .certificate(certificateResult):
			showScannedHealthCertificate(certificateResult)
		case let .traceLocation(traceLocation):
			showScannedCheckin(traceLocation)
		case let .ticketValidation(ticketValidationInitializationData):
			evaluateScannedTicketValidation(ticketValidationInitializationData)
		}
	}

	private func showScannedTestResult(
		_ testRegistrationInformation: CoronaTestRegistrationInformation
	) {
		if let recycleBinItemToRestore = recycleBinItemToRestore(for: testRegistrationInformation) {
			showTestRestoredFromBinAlert(recycleBinItem: recycleBinItemToRestore)
			return
		}

		qrScannerViewController?.dismiss(animated: true) { [weak self] in
			guard let self = self else { return }

			switch self.presenter {
			case .submissionFlow:
				self.didScanCoronaTestInSubmissionFlow?(testRegistrationInformation)
			case .onBehalfFlow:
				let parentPresentingViewController = self.parentViewController?.presentingViewController

				// Dismiss on behalf submission flow
				self.parentViewController?.dismiss(animated: true) {
					self.parentViewController = parentPresentingViewController

					guard let parentViewController = self.parentViewController else {
						return
					}

					let exposureSubmissionCoordinator = self.exposureSubmissionCoordinator(parentViewController: parentViewController)

					exposureSubmissionCoordinator.start(
						with: .success(testRegistrationInformation),
						markNewlyAddedCoronaTestAsUnseen: true
					)
				}
			case .checkinTab, .certificateTab, .universalScanner:
				guard let parentViewController = self.parentViewController else {
					return
				}

				let exposureSubmissionCoordinator = self.exposureSubmissionCoordinator(parentViewController: parentViewController)

				exposureSubmissionCoordinator.start(
					with: .success(testRegistrationInformation),
					markNewlyAddedCoronaTestAsUnseen: self.presenter != .universalScanner(.home)
				)
			case .none:
				break
			}
		}
	}
	
	private func showScannedHealthCertificate(
		_ certificateResult: CertificateResult
	) {
		guard let qrScannerViewController = self.qrScannerViewController else {
			return
		}

		showRestoredFromBinAlertIfNeeded(for: certificateResult, from: qrScannerViewController) { [weak self] in
			guard let self = self else { return }

			self.qrScannerViewController?.dismiss(animated: true) {
				switch self.presenter {
				case .submissionFlow, .onBehalfFlow:
					let parentPresentingViewController = self.parentViewController?.presentingViewController

					// Dismiss submission/on behalf submission flow
					self.parentViewController?.dismiss(animated: true) {
						self.parentViewController = parentPresentingViewController

						guard let parentViewController = self.parentViewController else {
							return
						}

						self.healthCertificateCoordinator = HealthCertificateCoordinator(
							parentingViewController: .present(parentViewController),
							healthCertifiedPerson: certificateResult.person,
							healthCertificate: certificateResult.certificate,
							store: self.store,
							healthCertificateService: self.healthCertificateService,
							healthCertificateValidationService: self.healthCertificateValidationService,
							healthCertificateValidationOnboardedCountriesProvider: self.healthCertificateValidationOnboardedCountriesProvider,
							vaccinationValueSetsProvider: self.vaccinationValueSetsProvider,
							markAsSeenOnDisappearance: false
						)

						self.healthCertificateCoordinator?.start()
					}
				case .checkinTab, .certificateTab, .universalScanner:
					guard let parentViewController = self.parentViewController else {
						return
					}

					self.healthCertificateCoordinator = HealthCertificateCoordinator(
						parentingViewController: .present(parentViewController),
						healthCertifiedPerson: certificateResult.person,
						healthCertificate: certificateResult.certificate,
						store: self.store,
						healthCertificateService: self.healthCertificateService,
						healthCertificateValidationService: self.healthCertificateValidationService,
						healthCertificateValidationOnboardedCountriesProvider: self.healthCertificateValidationOnboardedCountriesProvider,
						vaccinationValueSetsProvider: self.vaccinationValueSetsProvider,
						markAsSeenOnDisappearance: false
					)

					self.healthCertificateCoordinator?.start()
				case .none:
					break
				}
			}
		}
	}
	
	private func showScannedCheckin(
		_ traceLocation: TraceLocation
	) {
		qrScannerViewController?.dismiss(animated: true) {
			switch self.presenter {
			case .onBehalfFlow:
				self.didScanTraceLocationInOnBehalfFlow?(traceLocation)
			case .submissionFlow:
				let parentPresentingViewController = self.parentViewController?.presentingViewController

				// Dismiss submission flow
				self.parentViewController?.dismiss(animated: true) {
					self.parentViewController = parentPresentingViewController

					guard let parentViewController = self.parentViewController else {
						return
					}

					self.traceLocationCheckinCoordinator = TraceLocationCheckinCoordinator(
						parentViewController: parentViewController,
						traceLocation: traceLocation,
						store: self.store,
						eventStore: self.eventStore,
						appConfiguration: self.appConfiguration,
						eventCheckoutService: self.eventCheckoutService
					)

					self.traceLocationCheckinCoordinator?.start()
				}
			case .checkinTab, .certificateTab, .universalScanner:
				guard let parentViewController = self.parentViewController else {
					return
				}

				self.traceLocationCheckinCoordinator = TraceLocationCheckinCoordinator(
					parentViewController: parentViewController,
					traceLocation: traceLocation,
					store: self.store,
					eventStore: self.eventStore,
					appConfiguration: self.appConfiguration,
					eventCheckoutService: self.eventCheckoutService
				)

				self.traceLocationCheckinCoordinator?.start()
			case .none:
				break
			}
		}
	}

	private func evaluateScannedTicketValidation(
		_ initializationData: TicketValidationInitializationData
	) {
		showActivityIndicator()
		let ticketValidation = MockTicketValidation(with: initializationData)
		ticketValidation.delay = 1

		ticketValidation.initialize { [weak self] result in
			DispatchQueue.main.async {
				self?.hideActivityIndicator()

				switch result {
				case .success:
					self?.showScannedTicketValidation(ticketValidation)
				case .failure(let error):
					self?.showErrorAlert(error: error)
				}
			}
		}
	}

	private func showErrorAlert(error: TicketValidationError) {
		let alert = UIAlertController(
			title: AppStrings.TicketValidation.Error.title,
			message: error.localizedDescription,
			preferredStyle: .alert
		)

		alert.addAction(
			UIAlertAction(
				title: AppStrings.Common.alertActionOk,
				style: .default
			)
		)

		DispatchQueue.main.async {
			self.qrScannerViewController?.present(alert, animated: true)
		}
	}

	private func showScannedTicketValidation(
		_ ticketValidation: TicketValidating
	) {
		qrScannerViewController?.dismiss(animated: true) {
			switch self.presenter {
			case .onBehalfFlow, .submissionFlow:
				let parentPresentingViewController = self.parentViewController?.presentingViewController

				// Dismiss submission/on behalf submission flow
				self.parentViewController?.dismiss(animated: true) {
					self.parentViewController = parentPresentingViewController

					guard let parentViewController = self.parentViewController else {
						return
					}

					self.ticketValidationCoordinator = TicketValidationCoordinator(
						parentViewController: parentViewController,
						healthCertificateService: self.healthCertificateService
					)

					self.ticketValidationCoordinator?.start(ticketValidation: ticketValidation)
				}
			case .checkinTab, .certificateTab, .universalScanner:
				guard let parentViewController = self.parentViewController else {
					return
				}

				self.ticketValidationCoordinator = TicketValidationCoordinator(
					parentViewController: parentViewController,
					healthCertificateService: self.healthCertificateService
				)

				self.ticketValidationCoordinator?.start(ticketValidation: ticketValidation)
			case .none:
				break
			}
		}
	}

	private func showRestoredFromBinAlertIfNeeded(
		for certificateResult: CertificateResult,
		from presentationController: UIViewController,
		completion: @escaping () -> Void
	) {
		guard certificateResult.restoredFromBin else {
			completion()
			return
		}

		let alert = UIAlertController(
			title: AppStrings.UniversalQRScanner.certificateRestoredFromBinAlertTitle,
			message: AppStrings.UniversalQRScanner.certificateRestoredFromBinAlertMessage,
			preferredStyle: .alert
		)
		alert.addAction(
			UIAlertAction(
				title: AppStrings.Common.alertActionOk,
				style: .default,
				handler: { _ in
					completion()
				}
			)
		)

		presentationController.present(alert, animated: true)
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
				handler: { [weak self] _ in
					guard let self = self else { return }

					switch self.recycleBin.canRestore(recycleBinItem) {
					case .success:
						self.qrScannerViewController?.dismiss(animated: true) {
							switch self.presenter {
							case .submissionFlow, .onBehalfFlow:
								let parentPresentingViewController = self.parentViewController?.presentingViewController

								// Dismiss submission/on behalf submission flow
								parentPresentingViewController?.dismiss(animated: true) {
									self.parentViewController = parentPresentingViewController
									self.restoreAndShow(recycleBinItem: recycleBinItem)
								}
							case .checkinTab, .certificateTab, .universalScanner:
								self.restoreAndShow(recycleBinItem: recycleBinItem)
							case .none:
								break
							}
						}
					case .failure(.testError(.testTypeAlreadyRegistered)):
						self.showTestOverwriteNotice(recycleBinItem: recycleBinItem)
					}
				}
			)
		)

		qrScannerViewController?.present(alert, animated: true)
	}

	private func showTestOverwriteNotice(
		recycleBinItem: RecycleBinItem
	) {
		guard case let .coronaTest(coronaTest) = recycleBinItem.item else {
			return
		}

		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.ExposureSubmission.OverwriteNotice.primaryButton,
			isSecondaryButtonHidden: true
		)

		let overwriteNoticeViewController = TestOverwriteNoticeViewController(
			testType: coronaTest.type,
			didTapPrimaryButton: { [weak self] in
				self?.restoreAndShow(recycleBinItem: recycleBinItem)
			},
			didTapCloseButton: { [weak self] in
				self?.parentViewController?.dismiss(animated: true)
			}
		)

		let footerViewController = FooterViewController(footerViewModel)
		let topBottomViewController = TopBottomContainerViewController(
			topController: overwriteNoticeViewController,
			bottomController: footerViewController
		)

		let navigationController = NavigationControllerWithLargeTitle(rootViewController: topBottomViewController)

		switch self.presenter {
		case .submissionFlow, .onBehalfFlow:
			let parentPresentingViewController = self.parentViewController?.presentingViewController

			// Dismiss QR scanner and submission/on behalf submission flow at once
			parentPresentingViewController?.dismiss(animated: true) {
				self.parentViewController = parentPresentingViewController
				self.parentViewController?.present(navigationController, animated: true)
			}
		case .checkinTab, .certificateTab, .universalScanner:
			// Dismiss QR scanner
			parentViewController?.dismiss(animated: true) {
				self.parentViewController?.present(navigationController, animated: true)
			}
		case .none:
			break
		}
	}

	private func restoreAndShow(recycleBinItem: RecycleBinItem) {
		guard let parentViewController = self.parentViewController,
			  case .coronaTest(let coronaTest) = recycleBinItem.item else {
			return
		}

		self.recycleBin.restore(recycleBinItem)

		self.parentViewController?.dismiss(animated: true) {
			let exposureSubmissionCoordinator = self.exposureSubmissionCoordinator(parentViewController: parentViewController)
			exposureSubmissionCoordinator.start(with: coronaTest.type)
		}
	}

	private func showActivityIndicator() {
		guard let scannerView = qrScannerViewController?.view else {
			Log.error("Failed to get qrScannerViewController - stop", log: .fileScanner)
			return
		}
		activityIndicatorView.alpha = 0.0
		activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
		scannerView.addSubview(activityIndicatorView)
		NSLayoutConstraint.activate(
			[
				activityIndicatorView.topAnchor.constraint(equalTo: scannerView.layoutMarginsGuide.topAnchor),
				activityIndicatorView.bottomAnchor.constraint(equalTo: scannerView.layoutMarginsGuide.bottomAnchor),
				activityIndicatorView.leadingAnchor.constraint(equalTo: scannerView.leadingAnchor),
				activityIndicatorView.trailingAnchor.constraint(equalTo: scannerView.trailingAnchor)
			]
		)

		let animator = UIViewPropertyAnimator(duration: activityIndicatorAnimationDuration, curve: .easeIn) { [weak self] in
			self?.activityIndicatorView.alpha = 1.0
		}
		animator.startAnimation()
	}

	private func hideActivityIndicator() {
		let animator = UIViewPropertyAnimator(duration: activityIndicatorAnimationDuration, curve: .easeIn) { [weak self] in
			self?.activityIndicatorView.alpha = 0.0
		}
		animator.addCompletion { [weak self] _ in
			self?.activityIndicatorView.removeFromSuperview()
		}
		animator.startAnimation()
	}

	// MARK: Helpers

	private func exposureSubmissionCoordinator(
		parentViewController: UIViewController
	) -> ExposureSubmissionCoordinator {
		ExposureSubmissionCoordinator(
			parentViewController: parentViewController,
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: coronaTestService,
			healthCertificateService: healthCertificateService,
			healthCertificateValidationService: healthCertificateValidationService,
			eventProvider: eventStore,
			antigenTestProfileStore: store,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			healthCertificateValidationOnboardedCountriesProvider: healthCertificateValidationOnboardedCountriesProvider,
			qrScannerCoordinator: self
		)
	}

	private func recycleBinItemToRestore(
		for testRegistrationInformation: CoronaTestRegistrationInformation
	) -> RecycleBinItem? {
		switch testRegistrationInformation {
		case .pcr(guid: _, qrCodeHash: let qrCodeHash),
			.antigen(qrCodeInformation: _, qrCodeHash: let qrCodeHash):
			return store.recycleBinItems.first {
				guard case .coronaTest(let coronaTest) = $0.item else {
					return false
				}

				return coronaTest.qrCodeHash == qrCodeHash
			}
		case .teleTAN:
			return nil
		}
	}
	
}
