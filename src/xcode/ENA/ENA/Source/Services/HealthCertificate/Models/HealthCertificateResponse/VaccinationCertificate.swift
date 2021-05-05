////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

struct VaccinationCertificate: Codable, Equatable {

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case diseaseOrAgentTargeted = "tg"
		case vaccineOrProphylaxis = "vp"
		case vaccineMedicinalProduct = "mp"
		case marketingAuthorizationHolder = "ma"
		case doseNumber = "dn"
		case totalSeriesOfDoses = "sd"
		case dateOfVaccination = "dt"
		case countryOfVaccination = "co"
		case certificateIssuer = "is"
		case uniqueCertificateIdentifier = "ci"
	}

	// MARK: - Internal

	let diseaseOrAgentTargeted: String
	let vaccineOrProphylaxis: String
	let vaccineMedicinalProduct: String
	let marketingAuthorizationHolder: String

	let doseNumber: Int
	let totalSeriesOfDoses: Int

	let dateOfVaccination: String
	let countryOfVaccination: String
	let certificateIssuer: String
	let uniqueCertificateIdentifier: String

	var isEligibleForProofCertificate: Bool {
		doseNumber == totalSeriesOfDoses
	}

}
