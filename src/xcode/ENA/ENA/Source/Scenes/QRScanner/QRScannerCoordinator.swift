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
		let navigationController = UINavigationController(
			rootViewController: qrScannerViewController(
				markCertificateAsNew: presenter != .certificateTab && presenter != .universalScanner(.certificates),
				markCoronaTestAsNew: presenter != .submissionFlow && presenter != .universalScanner(.home)
			)
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
	private var healthCertificateCoordinator: HealthCertificateCoordinator?
	private var traceLocationCheckinCoordinator: TraceLocationCheckinCoordinator?
	private var onBehalfCheckinCoordinator: OnBehalfCheckinSubmissionCoordinator?
	private var fileScannerCoordinator: FileScannerCoordinator?

	private func qrScannerViewController(
		markCertificateAsNew: Bool,
		markCoronaTestAsNew: Bool
	) -> UIViewController {
		var qrScannerViewController: QRScannerViewController!
		qrScannerViewController = QRScannerViewController(
			healthCertificateService: healthCertificateService,
			appConfiguration: appConfiguration,
			markCertificateAsNew: markCertificateAsNew,
			markCoronaTestAsNew: markCoronaTestAsNew,
			didScan: { [weak self] qrCodeResult in
				self?.parentViewController?.dismiss(animated: true, completion: {
					switch qrCodeResult {
					case let .coronaTest(testRegistrationInformation):
						self?.showScannedTestResult(testRegistrationInformation)
					case let .certificate(healthCertifiedPerson, healthCertificate):
						self?.showScannedHealthCertificate(for: healthCertifiedPerson, with: healthCertificate)
					case let .traceLocation(traceLocation):
						self?.showScannedCheckin(traceLocation)
					}
				})
			},
			dismiss: { [weak self] in
				self?.parentViewController?.dismiss(animated: true)
			},
			presentFileScanner: { [weak self] in
				self?.fileScannerCoordinator = FileScannerCoordinator(
					qrScannerViewController,
					dismiss: {
						self?.fileScannerCoordinator = nil
					}
				)
				self?.fileScannerCoordinator?.start()
			}
		)
		return qrScannerViewController
	}

	private func showScannedTestResult(
		_ testRegistrationInformation: CoronaTestRegistrationInformation
	) {
		guard let parentViewController = parentViewController else {
			return
		}

		switch presenter {
		case .submissionFlow:
			didScanCoronaTestInSubmissionFlow?(testRegistrationInformation)
		case .onBehalfFlow:
			let parentPresentingViewController = parentViewController.presentingViewController

			parentViewController.dismiss(animated: true) {
				self.parentViewController = parentPresentingViewController

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

			exposureSubmissionCoordinator.start(with: .success(testRegistrationInformation), markNewlyAddedCoronaTestAsUnseen: true)
		case .none:
			break
		}
	}
	
	private func showScannedHealthCertificate(
		for person: HealthCertifiedPerson,
		with certificate: HealthCertificate
	) {
		guard let parentViewController = parentViewController else {
			return
		}

		switch presenter {
		case .submissionFlow, .onBehalfFlow:
			let parentPresentingViewController = parentViewController.presentingViewController

			parentViewController.dismiss(animated: true) {
				self.parentViewController = parentPresentingViewController

				self.healthCertificateCoordinator = HealthCertificateCoordinator(
					parentingViewController: .present(parentViewController),
					healthCertifiedPerson: person,
					healthCertificate: certificate,
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
			healthCertificateCoordinator = HealthCertificateCoordinator(
				parentingViewController: .present(parentViewController),
				healthCertifiedPerson: person,
				healthCertificate: certificate,
				store: store,
				healthCertificateService: healthCertificateService,
				healthCertificateValidationService: healthCertificateValidationService,
				healthCertificateValidationOnboardedCountriesProvider: healthCertificateValidationOnboardedCountriesProvider,
				vaccinationValueSetsProvider: vaccinationValueSetsProvider,
				markAsSeenOnDisappearance: false
			)

			healthCertificateCoordinator?.start()
		case .none:
			break
		}
	}
	
	private func showScannedCheckin(
		_ traceLocation: TraceLocation
	) {
		guard let parentViewController = parentViewController else {
			return
		}

		switch presenter {
		case .onBehalfFlow:
			didScanTraceLocationInOnBehalfFlow?(traceLocation)
		case .submissionFlow:
			let parentPresentingViewController = parentViewController.presentingViewController

			parentViewController.dismiss(animated: true) {
				self.parentViewController = parentPresentingViewController

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
	
}
