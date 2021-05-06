////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

struct ProofCertificate: Codable, Equatable {

	// MARK: - Init

	init(cborData: CBORData) throws {
		// Ensure the data will be decodable on the fly later on, even though we don't store the decoded data
		if case .failure(let error) = ProofCertificateAccess().extractCBORWebTokenHeader(from: cborData) {
			throw error
		}

		if case .failure(let error) = ProofCertificateAccess().extractDigitalGreenCertificate(from: cborData) {
			throw error
		}

		self.cborData = cborData
	}

	// MARK: - Internal

	var expirationDate: Date {
		Date(timeIntervalSince1970: Double(cborWebTokenHeader.expirationTime))
	}

	// MARK: - Private

	private let cborData: CBORData

	private var cborWebTokenHeader: CBORWebTokenHeader {
		let result = ProofCertificateAccess().extractCBORWebTokenHeader(from: cborData)

		switch result {
		case .success(let cborWebTokenHeader):
			return cborWebTokenHeader
		case .failure:
			fatalError("This")
		}
	}

	private var digitalGreenCertificate: DigitalGreenCertificate {
		let result = ProofCertificateAccess().extractDigitalGreenCertificate(from: cborData)

		switch result {
		case .success(let digitalGreenCertificate):
			return digitalGreenCertificate
		case .failure:
			fatalError("This")
		}
	}

}
