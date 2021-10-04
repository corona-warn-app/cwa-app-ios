//
// 🦠 Corona-Warn-App
//

@testable import ENA

class MockQRCodeParsable: QRCodeParsable {

	// MARK: - Init

	init(acceptAll: Bool) {
		self.accept = acceptAll
	}

	// MARK: - Protocol QRCodeParsable

	func parse(qrCode: String, completion: @escaping (Result<QRCodeResult, QRCodeParserError>) -> Void) {
		if accept {
			completion(.success(QRCodeResult.certificate(HealthCertifiedPerson(healthCertificates: []), HealthCertificate.mock()))
			)
		} else {
			completion(.failure(.checkinQrError(.codeNotFound)))
		}
	}

	// MARK: - Internal

	var accept: Bool = true
}
