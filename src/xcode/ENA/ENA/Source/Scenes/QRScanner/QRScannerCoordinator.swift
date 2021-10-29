//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

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
		coronaTestService: CoronaTestService
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
	
	private var presenter: QRScannerPresenter!
	private weak var parentViewController: UIViewController?
	private weak var qrScannerViewController: UIViewController?
	private var healthCertificateCoordinator: HealthCertificateCoordinator?
	private var traceLocationCheckinCoordinator: TraceLocationCheckinCoordinator?
	private var onBehalfCheckinCoordinator: OnBehalfCheckinSubmissionCoordinator?
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
					}
				)
				self?.fileScannerCoordinator?.start()
			}
		)
		return qrScannerViewController
	}

	private func showQRCodeResult(qrCodeResult: QRCodeResult) {
		parentViewController?.dismiss(animated: true, completion: { [weak self] in
			switch qrCodeResult {
			case let .coronaTest(testRegistrationInformation):
				self?.showScannedTestResult(testRegistrationInformation)
			case let .certificate(certificateResult):
				self?.showScannedHealthCertificate(certificateResult)
			case let .traceLocation(traceLocation):
				self?.showScannedCheckin(traceLocation)
			}
		})
	}

	private func showScannedTestResult(
		_ testRegistrationInformation: CoronaTestRegistrationInformation
	) {
//		let shouldBeRestoredFromBin: Bool
//		switch testRegistrationInformation {
//		case let .pcr(guid: _, qrCodeHash: qrCodeHash):
//			shouldBeRestoredFromBin = coronaTestService.pcrTest?.qrCodeHash == qrCodeHash
//		case let .antigen(qrCodeInformation: _, qrCodeHash: qrCodeHash):
//			shouldBeRestoredFromBin = coronaTestService.antigenTest?.qrCodeHash == qrCodeHash
//		case .teleTAN:
//			shouldBeRestoredFromBin = false
//		}
//
//		if shouldBeRestoredFromBin {
//			showTestRestoredFromBinAlert { [weak self] in
//				self?.
//
//				switch presenter {
//				case .submissionFlow, .onBehalfFlow:
//					self?.parentViewController?.dismiss(animated: true)
//				case .checkinTab, .certificateTab, .universalScanner, .none:
//					break
//				}
//			}
//		}

		switch presenter {
		case .submissionFlow:
			didScanCoronaTestInSubmissionFlow?(testRegistrationInformation)
		case .onBehalfFlow:
			let parentPresentingViewController = parentViewController?.presentingViewController

			parentViewController?.dismiss(animated: true) {
				self.parentViewController = parentPresentingViewController

				guard let parentViewController = self.parentViewController else {
					return
				}

				let exposureSubmissionCoordinator = ExposureSubmissionCoordinator(
					parentViewController: parentViewController,
					exposureSubmissionService: self.exposureSubmissionService,
					coronaTestService: self.coronaTestService,
					healthCertificateService: self.healthCertificateService,
					healthCertificateValidationService: self.healthCertificateValidationService,
					eventProvider: self.eventStore,
					antigenTestProfileStore: self.store,
					vaccinationValueSetsProvider: self.vaccinationValueSetsProvider,
					healthCertificateValidationOnboardedCountriesProvider: self.healthCertificateValidationOnboardedCountriesProvider,
					qrScannerCoordinator: self
				)

				exposureSubmissionCoordinator.start(with: .success(testRegistrationInformation), markNewlyAddedCoronaTestAsUnseen: true)
			}
		case .checkinTab, .certificateTab, .universalScanner:
			guard let parentViewController = parentViewController else {
				return
			}

			let markNewlyAddedCoronaTestAsUnseen: Bool = presenter != .universalScanner(.home)
			let exposureSubmissionCoordinator = ExposureSubmissionCoordinator(
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

			exposureSubmissionCoordinator.start(with: .success(testRegistrationInformation), markNewlyAddedCoronaTestAsUnseen: markNewlyAddedCoronaTestAsUnseen)
		case .none:
			break
		}
	}
	
	private func showScannedHealthCertificate(
		_ certificateResult: CertificateResult
	) {
		switch presenter {
		case .submissionFlow, .onBehalfFlow:
			let parentPresentingViewController = parentViewController?.presentingViewController

			parentViewController?.dismiss(animated: true) {
				self.parentViewController = parentPresentingViewController

				guard let parentViewController = self.parentViewController else {
					return
				}

				self.showRestoredFromBinAlertIfNeeded(for: certificateResult, from: parentViewController) {
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
			}
		case .checkinTab, .certificateTab, .universalScanner:
			guard let parentViewController = parentViewController else {
				return
			}

			self.showRestoredFromBinAlertIfNeeded(for: certificateResult, from: parentViewController) {
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
		case .none:
			break
		}
	}
	
	private func showScannedCheckin(
		_ traceLocation: TraceLocation
	) {
		switch presenter {
		case .onBehalfFlow:
			didScanTraceLocationInOnBehalfFlow?(traceLocation)
		case .submissionFlow:
			let parentPresentingViewController = parentViewController?.presentingViewController

			parentViewController?.dismiss(animated: true) {
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
			guard let parentViewController = parentViewController else {
				return
			}

			traceLocationCheckinCoordinator = TraceLocationCheckinCoordinator(
				parentViewController: parentViewController,
				traceLocation: traceLocation,
				store: store,
				eventStore: eventStore,
				appConfiguration: appConfiguration,
				eventCheckoutService: eventCheckoutService
			)

			traceLocationCheckinCoordinator?.start()
		case .none:
			break
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
		completion: @escaping () -> Void
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
					completion()
				}
			)
		)

		qrScannerViewController?.present(alert, animated: true)
	}
	
}
