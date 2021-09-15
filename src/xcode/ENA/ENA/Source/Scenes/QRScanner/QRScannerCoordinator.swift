//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

enum QRScanningResult {
	case test(TestResult)
	case certificate(HealthCertifiedPerson, HealthCertificate)
	case checkin(TraceLocation)
}

enum QRScanningError: Error {
	case someError
}

class QRScannerCoordinator: RequiresAppDependencies {
	
	// MARK: - Init
	
	init(
		homeCoordinator: HomeCoordinator,
		healthCertificatesCoordinator: HealthCertificatesCoordinator,
		checkinCoordinator: CheckinCoordinator
	) {
		self.homeCoordinator = homeCoordinator
		self.healthCertificatesCoordinator = healthCertificatesCoordinator
		self.checkinCoordinator = checkinCoordinator
	}
	
	// MARK: - Overrides
		
	// MARK: - Public
	
	// MARK: - Internal
	
	func showQRScanner() {
		
//		viewModel.scan(base45)
		let result: Result<QRScanningResult, QRScanningError>
		result = .failure(.someError)
		
		switch result {
		case let .success(scanningResult):
			switch scanningResult {
			case let .test(testResult):
				showScannedTestResult(testResult)
			case let .certificate(healthCertifiedPerson, healthCertificate):
				showScannedHealthCertificate(for: healthCertifiedPerson, with: healthCertificate)
			case let .checkin(traceLocation):
				showScannedCheckin(traceLocation)
			}
			
		case let .failure(error):
			showErrorAlert(for: error)
		}
	}
	
	// MARK: - Private
		
	private let homeCoordinator: HomeCoordinator
	private let healthCertificatesCoordinator: HealthCertificatesCoordinator
	private let checkinCoordinator: CheckinCoordinator

	private func showScannedTestResult(
		_ testResult: TestResult
	) {
//		homeCoordinator.showTestResultFlow()
	}
	
	private func showScannedHealthCertificate(
		for person: HealthCertifiedPerson,
		with certificate: HealthCertificate
	) {
		healthCertificatesCoordinator.showCertifiedPersonWithCertificateFromNotification(
			for: person,
			with: certificate
		)
	}
	
	private func showScannedCheckin(
		_ traceLocation: TraceLocation
	) {
//		checkinCoordinator.showCheckin()
	}
	
	private func showErrorAlert(
		for error: QRScanningError
	) {
		// show some alert.
	}
}
