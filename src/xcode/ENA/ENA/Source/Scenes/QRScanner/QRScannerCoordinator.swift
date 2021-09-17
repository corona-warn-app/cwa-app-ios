//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

// TODO: consent screen is shown twice for checkin tab and certificates tab. check if change required.

enum QRScannerPresenter {
	case submissionFlow
	case onBehalfFlow
	case checkinTab
	case certificateTab
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
	
	func start(
		parentViewController: UIViewController,
		presenter: QRScannerPresenter
	) {
		self.parentViewController = parentViewController
		self.presenter = presenter
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
	private let qrCodeVerificationHelper = QRCodeVerificationHelper()
	
	private var presenter: QRScannerPresenter!
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
			healthCertificateService: healthCertificateService,
			verificationHelper: qrCodeVerificationHelper,
			appConfiguration: appConfiguration,
			didScan: { [weak self] result in
				switch result {
				case let .success(scanningResult):
					// Close the qr scanner
					self?.parentViewController.dismiss(animated: true)
					
					switch scanningResult {
					case let .coronaTest(testRegistrationInformation):
						self?.showScannedTestResult(testRegistrationInformation)
					case let .certificate(healthCertifiedPerson, healthCertificate):
						self?.showScannedHealthCertificate(for: healthCertifiedPerson, with: healthCertificate)
					case let .traceLocation(traceLocation):
						self?.showScannedCheckin(traceLocation)
					}
					
				case let .failure(error):
					// TODO: should we dismiss here the qrCodescanner, too?
					// TODO: show alert for permission missing, specific error should handle the presenters
					self?.parentViewController.dismiss(animated: true)
				}
			},
			dismiss: { [weak self] in
				self?.parentViewController.dismiss(animated: true)
			}
		)
	}()
	
	
	private func showScannedTestResult(
		_ testRegistrationInformation: CoronaTestRegistrationInformation
	) {
		switch presenter {
		case .submissionFlow:
			//TODO call completion of submission flow
			break
		case .onBehalfFlow:
			//TODO: close modal onBehalf, then present exposureSubmissionCoordinator
			break
		default:
			// we come from certificate tab or checkin tab
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
	}
	
	private func showScannedHealthCertificate(
		for person: HealthCertifiedPerson,
		with certificate: HealthCertificate
	) {
		// TODO dismiss first the qrScannerViewController and then present the flow
		healthCertificateCoordinator = HealthCertificateCoordinator(
			parentingViewController: .present(parentViewController),
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
		switch presenter {
		case .onBehalfFlow:
			// TODO: call completion of onBehalfCoordinator
			break
		default:
			traceLocationCheckinCoordinator = TraceLocationCheckinCoordinator(
				parentViewController: parentViewController,
				traceLocation: traceLocation,
				store: store,
				eventStore: eventStore,
				appConfiguration: appConfiguration,
				eventCheckoutService: eventCheckoutService
			)
			
			traceLocationCheckinCoordinator?.start()
		}
		
	}
	
	/*
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
*/
	
}
