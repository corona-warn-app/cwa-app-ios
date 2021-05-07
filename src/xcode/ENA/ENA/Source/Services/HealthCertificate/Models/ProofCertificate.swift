////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

struct ProofCertificate: Codable, Equatable {

	// MARK: - Init

	init(cborData: CBORData) throws {
		// Ensure the data will be decodable on the fly later on, even though we don't store the decoded data
		if case .failure(let error) = DigitalGreenCertificateAccess().extractCBORWebTokenHeader(from: cborData) {
			throw error
		}

		if case .failure(let error) = DigitalGreenCertificateAccess().extractDigitalGreenCertificate(from: cborData) {
			throw error
		}

		self.cborData = cborData
	}

	// MARK: - Internal

	var expirationDate: Date {
		Date(timeIntervalSince1970: TimeInterval(cborWebTokenHeader.expirationTime))
	}

	var isExpired: Bool {
		Date() >= expirationDate
	}

	// MARK: - Private

	private let cborData: CBORData

	private var cborWebTokenHeader: CBORWebTokenHeader {
		let result = DigitalGreenCertificateAccess().extractCBORWebTokenHeader(from: cborData)

		switch result {
		case .success(let cborWebTokenHeader):
			return cborWebTokenHeader
		case .failure:
			fatalError("Decoding the cborWebTokenHeader failed even though decodability was checked at initialization.")
		}
	}

	private var digitalGreenCertificate: DigitalGreenCertificate {
		let result = DigitalGreenCertificateAccess().extractDigitalGreenCertificate(from: cborData)

		switch result {
		case .success(let digitalGreenCertificate):
			return digitalGreenCertificate
		case .failure:
			fatalError("Decoding the digitalGreenCertificate failed even though decodability was checked at initialization.")
		}
	}

}
