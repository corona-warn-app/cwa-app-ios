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

class QRScannerCoordinator: RequiresAppDependencies {
	
	// MARK: - Init
	
	init(
		homeCoordinator: HomeCoordinator,
		healthCertificatesCoordinator: HealthCertificatesCoordinator,
		checkinCoordinator: CheckinCoordinator,
		exposureSubmissionCoordinator: ExposureSubmissionCoordinator
	) {
		self.homeCoordinator = homeCoordinator
		self.healthCertificatesCoordinator = healthCertificatesCoordinator
		self.checkinCoordinator = checkinCoordinator
		self.exposureSubmissionCoordinator = exposureSubmissionCoordinator
		
		self.qrScanningNavigationController = DismissHandlingNavigationController(rootViewController: QRScannerViewController())
	}
	
	// MARK: - Overrides
		
	// MARK: - Public
	
	// MARK: - Internal
	
	func showQRScanner(
		onNavigationController: UINavigationController
	) {
		qrScanningNavigationController = onNavigationController
//		viewModel.scan(base45)
		let result: Result<QRScanningResult, QRScanningError>
		result = .failure(.someError)
		
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
	
	// MARK: - Private
	
	private let homeCoordinator: HomeCoordinator
	private let healthCertificatesCoordinator: HealthCertificatesCoordinator
	private let checkinCoordinator: CheckinCoordinator
	private let exposureSubmissionCoordinator: ExposureSubmissionCoordinator
	
	private var qrScanningNavigationController: UINavigationController
	
	private func showScannedTestResult(
		_ testRegistrationInformation: CoronaTestRegistrationInformation
	) {
		self.exposureSubmissionCoordinator.showRegisterTestFlowFromQRScanner(
			on: self.qrScanningNavigationController,
			supportedCountries: [Country(countryCode: "DE")!],
			with: testRegistrationInformation
		)
	}
	
	private func showScannedHealthCertificate(
		for person: HealthCertifiedPerson,
		with certificate: HealthCertificate
	) {
//		healthCertificatesCoordinator.showCertifiedPersonWithCertificateFromQRScanner(
//			on: qrScanningNavigationController,
//			for: person,
//			with: certificate
//		)
	}
	
	private func showScannedCheckin(
		_ traceLocation: TraceLocation
	) {
		checkinCoordinator.showTraceLocationDetailsFromQRScanner(
			on: qrScanningNavigationController,
			with: traceLocation
		)
	}
	
	private func showScannedOnBehalf(
		_ traceLocation: TraceLocation
	) {
		checkinCoordinator.showTraceLocationDetailsFromQRScanner(
			on: qrScanningNavigationController,
			with: traceLocation
		)
	}
	
	private func showErrorAlert(
		for error: QRScanningError
	) {
		// show some alert.
	}
}
