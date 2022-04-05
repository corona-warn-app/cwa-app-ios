//
// 🦠 Corona-Warn-App
//

import Foundation

class HealthCertificateQRCodeParser: QRCodeParsable {
	
	// MARK: - Init

	init(
		healthCertificateService: HealthCertificateService,
		markAsNew: Bool
	) {
		self.healthCertificateService = healthCertificateService
		self.markAsNew = markAsNew
	}

	// MARK: - Protocol QRCodeParsable
	
	func parse(
		qrCode: String,
		completion: @escaping (Result<QRCodeResult, QRCodeParserError>) -> Void
	) {
		Log.info("Parse health certificate.")

		// To speed up the process, we are not waiting for notification registration.
		// The parsing of the certificate only happens in foreground at the moment.
		// Its unlikly that the registration of notifications will be killed at this point.
		let result = healthCertificateService.registerHealthCertificate(base45: qrCode, markAsNew: markAsNew, completedNotificationRegistration: {  })
		
		switch result {
		case let .success(certificateResult):
			Log.info("Successfuly parsed health certificate.")
			completion(.success(.certificate(certificateResult)))
		case .failure(let registrationError):
			Log.info("Failed parsing health certificate with error: \(registrationError)")
			// wrap RegistrationError into an QRScannerError.other error
			completion(.failure(.certificateQrError(registrationError)))
		}
	}
	
	// MARK: - Private

	private let healthCertificateService: HealthCertificateService
	private let markAsNew: Bool

}
