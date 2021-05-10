////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

struct ProofCertificate: Codable, Equatable {

	// MARK: - Init

	init(base45: Base45) throws {
		// Ensure the data will be decodable on the fly later on, even though we don't store the decoded data
		if case .failure(let error) = DigitalGreenCertificateAccess().extractCBORWebTokenHeader(from: base45) {
			throw error
		}

		if case .failure(let error) = DigitalGreenCertificateAccess().extractDigitalGreenCertificate(from: base45) {
			throw error
		}

		self.base45 = base45
	}

	// MARK: - Internal

	var expirationDate: Date {
		Date(timeIntervalSince1970: TimeInterval(cborWebTokenHeader.expirationTime))
	}

	var isExpired: Bool {
		Date() >= expirationDate
	}

	// MARK: - Private

	private let base45: Base45

	private var cborWebTokenHeader: CBORWebTokenHeader {
		let result = DigitalGreenCertificateAccess().extractCBORWebTokenHeader(from: base45)

		switch result {
		case .success(let cborWebTokenHeader):
			return cborWebTokenHeader
		case .failure:
			fatalError("Decoding the cborWebTokenHeader failed even though decodability was checked at initialization.")
		}
	}

	private var digitalGreenCertificate: DigitalGreenCertificate {
		let result = DigitalGreenCertificateAccess().extractDigitalGreenCertificate(from: base45)

		switch result {
		case .success(let digitalGreenCertificate):
			return digitalGreenCertificate
		case .failure:
			fatalError("Decoding the digitalGreenCertificate failed even though decodability was checked at initialization.")
		}
	}

}
