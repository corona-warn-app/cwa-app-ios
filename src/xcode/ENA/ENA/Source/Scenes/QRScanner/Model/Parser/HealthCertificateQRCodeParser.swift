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

		let result = healthCertificateService.registerHealthCertificate(base45: qrCode, markAsNew: markAsNew)
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
