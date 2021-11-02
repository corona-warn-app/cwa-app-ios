//
// 🦠 Corona-Warn-App
//

@testable import ENA

class QRCodeParsableMock: QRCodeParsable {

	// MARK: - Init

	init(acceptAll: Bool, certificate: HealthCertificate) {
		self.accept = acceptAll
		self.certificate = certificate
	}

	// MARK: - Protocol QRCodeParsable

	func parse(qrCode: String, completion: @escaping (Result<QRCodeResult, QRCodeParserError>) -> Void) {

		if accept {
			completion(.success(
				QRCodeResult.certificate(
					CertificateResult(
						restoredFromBin: false,
						person: HealthCertifiedPerson(healthCertificates: []),
						certificate: certificate
					)
				)
			)
			)
		} else {
			completion(.failure(.checkinQrError(.codeNotFound)))
		}
	}

	// MARK: - Internal

	var accept: Bool = true
	let certificate: HealthCertificate
}
