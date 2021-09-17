//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

enum QRScanningResult {
	case test(CoronaTestRegistrationInformation)
	case certificate(HealthCertifiedPerson, HealthCertificate)
	case checkin(TraceLocation)
	case onBehalf(TraceLocation)
}

enum QRScanningError: Error {
	case someError
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
	
	// MARK: - Overrides
		
	// MARK: - Public
	
	// MARK: - Internal
	
	// TODO: missing the info from where we come to decide the notification
	func start(
		from parentViewController: UIViewController
	) {
		self.parentViewController = parentViewController
		let navigationController = UINavigationController(rootViewController: qrScannerViewController)
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
	
	private var parentViewController: UIViewController!
	private var healthCertificateCoordinator: HealthCertificateCoordinator?
	private var traceLocationCheckinCoordinator: TraceLocationCheckinCoordinator?
	private var exposureSubmissionCoordinator: ExposureSubmissionCoordinator?
	private var onBehalfCheckinCoordinator: OnBehalfCheckinSubmissionCoordinator?
	
	private lazy var rootNavigationController: UINavigationController = {
		return UINavigationController(rootViewController: qrScannerViewController)
	}()
	
	private lazy var qrScannerViewController: UIViewController = {
		return QRScannerViewController(
			
			/*
			didQRScan { result in
			switch result {
			case let .success(scanningResult):
				switch scanningResult {
				case let .test(testRegistrationInformation):
					showScannedTestResult(testRegistrationInformation)
				case let .certificate(healthCertifiedPerson, healthCertificate):
					showScannedHealthCertificate(for: healthCertifiedPerson, with: healthCertificate)
				case let .checkin(traceLocation):
					showScannedCheckin(traceLocation)
				case let .onBehalf(traceLocation):
					showScannedOnBehalf(traceLocation)
				}
				
			case let .failure(error):
				showErrorAlert(for: error)
			}
			
			
			}
			*/
		)
	}()
	
	
	private func showScannedTestResult(
		_ testRegistrationInformation: CoronaTestRegistrationInformation
	) {
		exposureSubmissionCoordinator = ExposureSubmissionCoordinator(
			parentViewController: parentViewController,
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: coronaTestService,
			healthCertificateService: healthCertificateService,
			healthCertificateValidationService: healthCertificateValidationService,
			eventProvider: eventStore,
			antigenTestProfileStore: store,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			healthCertificateValidationOnboardedCountriesProvider: healthCertificateValidationOnboardedCountriesProvider
		)
		exposureSubmissionCoordinator?.start(with: .success(testRegistrationInformation))
	}
	
	private func showScannedHealthCertificate(
		for person: HealthCertifiedPerson,
		with certificate: HealthCertificate
	) {
		// TODO dismiss first the qrScannerViewController and then present the flow
		healthCertificateCoordinator = HealthCertificateCoordinator(
			parentingViewController: .present(qrScannerViewController),
			healthCertifiedPerson: person,
			healthCertificate: certificate,
			store: store,
			healthCertificateService: healthCertificateService,
			healthCertificateValidationService: healthCertificateValidationService,
			healthCertificateValidationOnboardedCountriesProvider: healthCertificateValidationOnboardedCountriesProvider,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider
		)
		
		healthCertificateCoordinator?.start()
	}
	
	private func showScannedCheckin(
		_ traceLocation: TraceLocation
	) {
		traceLocationCheckinCoordinator = TraceLocationCheckinCoordinator(
			parentViewController: qrScannerViewController,
			traceLocation: traceLocation,
			store: store,
			eventStore: eventStore,
			appConfiguration: appConfiguration,
			eventCheckoutService: eventCheckoutService
		)
		
		traceLocationCheckinCoordinator?.start()
	}
	
	private func showScannedOnBehalf(
		_ traceLocation: TraceLocation
	) {
		// TODO: clarify if consent should be also shown after qr scanning. If yes, flow must be changed and this would be the approch:
		onBehalfCheckinCoordinator = OnBehalfCheckinSubmissionCoordinator(
			parentViewController: qrScannerViewController,
			appConfiguration: appConfiguration,
			eventStore: eventStore,
			client: client
		)
		
		onBehalfCheckinCoordinator?.start()
		
		// TODO: IF NOT, this would be the approach:
//		checkinCoordinator.showTraceLocationDetailsFromQRScanner(
//			on: qrScanningNavigationController,
//			with: traceLocation
//		)
	}
	
	private func showErrorAlert(
		for error: QRScanningError
	) {
		// show some alert.
	}
}
