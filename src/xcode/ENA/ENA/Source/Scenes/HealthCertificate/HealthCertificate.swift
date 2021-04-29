////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class HealthCertifiedPerson: OpenCombine.ObservableObject, Codable {

	init(proofCertificate: ProofCertificate?, healthCertificates: [HealthCertificate]) {
		self.proofCertificate = proofCertificate
		self.healthCertificates = healthCertificates
	}

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case proofCertificate
		case healthCertificates
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		proofCertificate = try container.decode(ProofCertificate.self, forKey: .proofCertificate)
		healthCertificates = try container.decode([HealthCertificate].self, forKey: .healthCertificates)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(proofCertificate, forKey: .proofCertificate)
		try container.encode(healthCertificates, forKey: .healthCertificates)
	}

	// MARK: - Internal

	@OpenCombine.Published var proofCertificate: ProofCertificate?
	@OpenCombine.Published var healthCertificates: [HealthCertificate]

}

struct ProofCertificate: Codable {

	// MARK: - Internal

	let cborRepresentation: Data
	let expirationDate: Date

}

struct HealthCertificate: Codable {

	// MARK: - Internal

	let codableHealthCertificate: CodableHealthCertificate
	let representations: HealthCertificateRepresentations

	var version: String {
		codableHealthCertificate.version
	}

	var name: HealthCertificateName {
		codableHealthCertificate.name
	}

	var dateOfBirth: String {
		codableHealthCertificate.dateOfBirth
	}

	var vaccinationCertificates: [VaccinationCertificate] {
		codableHealthCertificate.vaccinationCertificates
	}

}

struct CodableHealthCertificate: Codable {

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case version = "ver"
		case name = "nam"
		case dateOfBirth = "dob"
		case vaccinationCertificates = "v"
	}

	// MARK: - Internal

	let version: String
	let name: HealthCertificateName
	let dateOfBirth: String
	let vaccinationCertificates: [VaccinationCertificate]

}

struct HealthCertificateName: Codable {

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case familyName = "fn"
		case givenName = "gn"
		case standardizedFamilyName = "fnt"
		case standardizedGivenName = "gnt"
	}

	// MARK: - Internal

	let familyName: String
	let givenName: String
	let standardizedFamilyName: String
	let standardizedGivenName: String

}

struct VaccinationCertificate: Codable {

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

}

struct HealthCertificateRepresentations: Codable {

	// MARK: - Internal

	let base45: String
	let cbor: Data
	let json: Data

}

class HealthCertificateService {

	// MARK: - Init

	init(
		store: HealthCertificateStoring
	) {
		self.store = store

		setup()
	}

	// MARK: - Internal

	@OpenCombine.Published /*private(set)*/ var healthCertifiedPersons: [HealthCertifiedPerson] = []

	func updatePublishersFromStore() {
		Log.info("[HealthCertificateService] Updating publishers from store", log: .api)

		healthCertifiedPersons = store.healthCertifiedPersons
	}

	// MARK: - Private

	private var store: HealthCertificateStoring

	private var subscriptions = Set<AnyCancellable>()

	private func setup() {
		updatePublishersFromStore()

		$healthCertifiedPersons
			.sink { [weak self] healthCertifiedPersons in
				self?.store.healthCertifiedPersons = healthCertifiedPersons
			}
			.store(in: &subscriptions)
	}

}
