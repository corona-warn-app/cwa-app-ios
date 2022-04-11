//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftUI

protocol RevocationProviding {
	func updateCache(with certificates: [HealthCertificate], completion: @escaping (Result<Void, RevocationProvider.RevocationProviderError>) -> Void)
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

	// MARK: - Protocol RevocationProviding

	func updateCache(with certificates: [HealthCertificate], completion: @escaping (Result<Void, RevocationProviderError>) -> Void) {
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
				completion(.failure(.restError(error)))
			case .success(let kidList):
				// helping step -> convert to KidWithTypes model to make things a bit easier
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
				// incl. 6. Group by RLC by KID Type
				self.certificateByRLC = []
				for kidWithTypes in keyIdentifiersWithTypes {
					let kid = kidWithTypes.kid
					guard let certificates = filteredGroupedCertificates[kid] else {
						Log.info("no matching certificates found, nothing to do for that kid")
						continue
					}

					let kidTypes = kidWithTypes.types
					for certificate in certificates {
						for type in kidTypes {
							self.insert(kid, type, certificate)
						}
					}
				}
				self.certificateByRLC.sort { lhs, rhs in
					lhs.type < rhs.type
				}
			}

			self.updateKidType { result in
				switch result {
				case .success:
					completion(.success(()))
				case .failure(let error):
					completion(.failure(error))
				}
			}
		}
	}

	// MARK: - Public

	// MARK: - Internal

	enum RevocationProviderError: Error {
		case internalError
		case chunkUpdateError
		case restError(ServiceError<KIDListResourceError>)
	}

	// MARK: - Private

	private struct KidWithTypes {
		let kid: String
		let types: [String]
	}

	private let restService: RestServiceProvider
	private let signatureVerifier: SignatureVerification

	private(set) var certificateByRLC: [RevocationLocation] = []

	private func updateKidType(completion: @escaping(Result<Void, RevocationProviderError>) -> Void) {
		// first we need a copy, inside the loop data of certificateByRLC will get modified
		let copyOfCertificateByRLC = certificateByRLC
		for rlc in copyOfCertificateByRLC {
			// 1 update KID Types
			updateKidTypeIndex(rlc.keyIdentifier, rlc.type) { [weak self] coordinates in
				guard let self = self else {
					Log.error("Failed to get strong self")
					completion(.failure(.internalError))
					return
				}
				// 2 filter for RLC
				let effectedCertificates = rlc.certificates.filter { key, _ in
					coordinates.contains(key)
				}
				// 3 update KID Type chunk
				effectedCertificates.forEach { coordinate, _ in
					let resource = KIDTypeChunkResource(kid: rlc.keyIdentifier, hashType: rlc.type, x: coordinate.x, y: coordinate.y)
					self.restService.load(resource) { result in
						switch result {
						case .success(let kidChunk):
							// 4 remove all certificates with matching hash
							let hashes = kidChunk.hashes.map { $0.toHexString() }
							hashes.forEach { hash in
								self.removeCertificateByHash(hash)
							}
						case .failure(let error):
							Log.error("failed to update kid x y chunk", error: error)
							completion(.failure(.chunkUpdateError))
						}
					}
				}
			}
		}
	}

	private func removeCertificateByHash(_ hash: String) {
		var result: [RevocationLocation] = []
		for revocationLocation in certificateByRLC {
			let updatedCertificates = revocationLocation.certificates.map { key, values in
				[key: values.filter({ certificate in
					let certificateHash = self.hash(by: revocationLocation.type, certificate)
					return certificateHash != hash
				})]
			}
			guard !updatedCertificates.isEmpty else {
				continue
			}

			result.append(revocationLocation)
		}
		certificateByRLC = result
	}

	private func updateKidTypeIndex(_ kid: String, _ hash: String, completion: @escaping([RevocationLocation.Coordinate]) -> Void) {
		let resource = KIDTypeIndexResource(kid: kid, hashType: hash)
		restService.load(resource) { result in
			switch result {
			case .success(let kidTypeIndices):
				completion(
					kidTypeIndices.items.map { item -> RevocationLocation.Coordinate in
						RevocationLocation.Coordinate(
							x: item.x.toHexString(),
							y: item.y[0].toHexString()
						)
					}
				)
			case .failure(let error):
				Log.error("Failed to load kid type indices", error: error)
			}
		}
	}

	private func insert(_ kid: String, _ type: String, _ certificate: HealthCertificate) {
		guard let hash = hash(by: type, certificate) else {
			Log.error("missing hash, type might be unknown")
			return
		}
		let coordinate = rlc(hash)

		// lookup or create entry
		guard let entry = certificateByRLC.first(where: { rlc in
			rlc.keyIdentifier == kid && rlc.type == type
		}) else {
			// no entry found create a new one and add
			certificateByRLC.append(
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
		certificateByRLC.replace(entry, with: updatedEntry)
	}

	private func rlc(_ hash: String) -> RevocationLocation.Coordinate {
		let data = Data(hex: hash)
		let first = Data(bytes: [data[0]], count: 1)
		let second = Data(bytes: [data[1]], count: 1)

		return RevocationLocation.Coordinate(
			x: first.toHexString(),
			y: second.toHexString()
		)
	}

	private func hash(by type: String, _ certificate: HealthCertificate) -> String? {
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
