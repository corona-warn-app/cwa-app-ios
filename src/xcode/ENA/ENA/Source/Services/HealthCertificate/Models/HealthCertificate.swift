////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

struct HealthCertificate: Codable, Equatable {

	// MARK: - Init

	init(base45: Base45) throws {
		// Ensure the data will be decodable on the fly later on, even though we don't store the decoded data
		if case .failure(let error) = HealthCertificateAccess().extractCBORWebTokenHeader(from: base45) {
			throw error
		}

		if case .failure(let error) = HealthCertificateAccess().extractDigitalGreenCertificate(from: base45) {
			throw error
		}

		self.base45 = base45
	}

	// MARK: - Internal

	let base45: Base45

	var version: String {
		digitalGreenCertificate.version
	}

	var name: HealthCertificateToolkit.Name {
		digitalGreenCertificate.name
	}

	var dateOfBirth: String {
		digitalGreenCertificate.dateOfBirth
	}

	var vaccinationCertificates: [VaccinationCertificate] {
		digitalGreenCertificate.vaccinationCertificates
	}

	private var cborWebTokenHeader: CBORWebTokenHeader {
		let result = HealthCertificateAccess().extractCBORWebTokenHeader(from: base45)

		switch result {
		case .success(let cborWebTokenHeader):
			return cborWebTokenHeader
		case .failure:
			fatalError("Decoding the cborWebTokenHeader failed even though decodability was checked at initialization.")
		}
	}

	private var digitalGreenCertificate: DigitalGreenCertificate {
		let result = HealthCertificateAccess().extractDigitalGreenCertificate(from: base45)

		switch result {
		case .success(let digitalGreenCertificate):
			return digitalGreenCertificate
		case .failure:
			fatalError("Decoding the digitalGreenCertificate failed even though decodability was checked at initialization.")
		}
	}

}
