//
// 🦠 Corona-Warn-App
//

import Foundation

// this should replace HealthCertificateQRCodeScannerViewModel
class CertificateQRCodeParser: QRCodeParsable {
	
	// MARK: - Init

	init(healthCertificateService: HealthCertificateService) {
		self.healthCertificateService = healthCertificateService
	}
	
	func parse(qrCode: String, completion: @escaping (Result<QRCodeResult, QRCodeParserError>) -> Void) {
		let result = healthCertificateService.registerHealthCertificate(base45: qrCode)
		switch result {
		case let .success((healthCertifiedPerson, healthCertificate)):
			completion(.success(.certificate(healthCertifiedPerson, healthCertificate)))
		case .failure(let registrationError):
			// wrap RegistrationError into an QRScannerError.other error
			completion(.failure(.scanningError(.other(registrationError))))
		}
	}
	
	// MARK: - Private

	private let healthCertificateService: HealthCertificateService
}
