//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftUI

protocol RevocationProviding {

	func updateCache(with certificates: [HealthCertificate], completion: @escaping (Result<Void, Error>) -> Void)
}

final class RevocationProvider: RevocationProviding {

	// MARK: - Init

	init(
		_ restService: RestServiceProvider,
		signatureVerifier: SignatureVerification = SignatureVerifier()
	) {
		self.restService = restService
		self.signatureVerifier = signatureVerifier
	}

	// MARK: - Overrides

	// MARK: - Protocol RevocationProviding

	func updateCache(with certificates: [HealthCertificate], completion: @escaping (Result<Void, Error>) -> Void) {
		// 1. Filter by certificate type
		let filteredCertificates = certificates.filter { certificate in
			(certificate.type == .vaccination ||
			 certificate.type == .recovery) &&
			certificate.keyIdentifier != nil
		}

		// 2. group certificates by kid
		let groupedCertificates = Dictionary(grouping: filteredCertificates) { element in
			element.keyIdentifier ?? ""
		}

		// 3. Update KID List
		let resource = KIDListResource(signatureVerifier: signatureVerifier)
		restService.load(resource) { result in
			switch result {
			case .failure(let error):
				completion(.failure(error))
			case .success(let kidList):
				// helping step -> convert to another model
				let keyIdentifiersWithTypes: [KidWithTypes] = kidList.items.map {
					let keyIdentifier = $0.kid.base64EncodedString()
					let types = $0.hashTypes.map { $0.hexEncodedString() }
					return KidWithTypes(
						kid: keyIdentifier,
						types: types
					)
				}

				// 4. filter certificates for kid
				let kids = keyIdentifiersWithTypes.map { $0.kid }
				let filteredGroupedCertificates = groupedCertificates
					.filter { !$0.key.isEmpty }
					.filter { kids.contains($0.key) }

				// 5. calculate revocation coordinates based on kid list for ever filteredGroupedCertificates
				let manager = RLCManager()
				for kidWithTypes in keyIdentifiersWithTypes {
					let kid = kidWithTypes.kid
					guard let certificates = filteredGroupedCertificates[kid] else {
						Log.info("no matching certificates found, nothing to do for that kid")
						continue
					}

					let kidTypes = kidWithTypes.types
					for certificate in certificates {
						for type in kidTypes {
							manager.insert(kid, type, certificate)
						}
					}
				}
			}

			// 6. -> [RevocationLocationCoordinates]

			Log.info("Did load KidListe")
			completion(.success(()))
		}
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let restService: RestServiceProvider
	private let signatureVerifier: SignatureVerification
	private let queue: DispatchQueue = DispatchQueue(label: "RevocationServiceQueue")

	/// write to store
	private var lastExecution: Date = Date()

}

struct KidWithTypes {
	let kid: String
	let types: [String]
}

class RLCManager {

	var data: [RevocationLocation] = []

	func insert(_ kid: String, _ type: String, _ certificate: HealthCertificate) {
		guard let hash = hash(type, certificate) else {
			Log.error("missing hash, type might be unknown")
			return
		}
		let coordinate = rlc(type, hash)

		// lookup or create entry
		guard let entry = data.first(where: { rlc in
			rlc.keyIdentifier == kid && rlc.type == type
		}) else {
			// no entry found create a new one and add
			data.append(
				RevocationLocation(
					keyIdentifier: kid,
					type: type,
					certificates: [coordinate: [certificate]]
				)
			)
			return
		}
		var updatedEntry = entry
		var certificatesByCoordinate = entry.certificates[coordinate] ?? []
		certificatesByCoordinate.append(certificate)
		updatedEntry.certificates[coordinate] = certificatesByCoordinate
		data.replace(entry, with: updatedEntry)
	}

	private func rlc(_ type: String, _ hash: String) -> RevocationLocation.Coordinate {
		let data = Data(hex: hash)
		let first = Data(bytes: [data[0]], count: 1)
		let second = Data(bytes: [data[0]], count: 1)

		return RevocationLocation.Coordinate(
			x: first.toHexString(),
			y: second.toHexString()
		)
	}

	private func hash(_ type: String, _ certificate: HealthCertificate) -> String? {
		switch type {
		case "0a":
			return certificate.revocationEntries.signature
		case "0b":
			return certificate.revocationEntries.uci
		case "0c":
			return certificate.revocationEntries.countryCodeUCI
		default:
			return nil
		}
	}
}

struct RevocationLocation: Hashable {

	struct Coordinate: Hashable {
		let x: String
		let y: String
	}

	// MARK: Protocol - Hashable

	func hash(into hasher: inout Hasher) {
		hasher.combine(keyIdentifier)
		hasher.combine(type)
	}

	// MARK: Internal

	let keyIdentifier: String
	let type: String
	var certificates: [Coordinate: [HealthCertificate]]
}

extension HealthCertificate: Hashable {

	func hash(into hasher: inout Hasher) {
		hasher.combine(base45)
		hasher.combine(keyIdentifier)
	}

}
