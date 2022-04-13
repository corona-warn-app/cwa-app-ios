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
		_ restService: RestServiceProviding,
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
			 certificate.type == .recovery)
		}

		// 2. group certificates by kid
		let groupedCertificates = Dictionary(grouping: filteredCertificates) { element in
			Data(base64Encoded: element.keyIdentifier)?.toHexString() ?? ""
		}

		// 3. Update KID List
		let resource = KIDListResource(signatureVerifier: signatureVerifier)
		restService.load(resource) { [weak self] result in
			guard let self = self else {
				Log.error("Failed to get strong self")
				completion(.failure(.internalError))
				return
			}

			switch result {
			case .failure(let error):
				completion(.failure(.restError(error)))
			case .success(let kidList):
				// helping step -> convert to KidWithTypes model to make things a bit easier
				let keyIdentifiersWithTypes: [KidWithTypes] = kidList.items.map {
					let keyIdentifier = $0.kid.toHexString()
					let types = $0.hashTypes.map { $0.toHexString() }
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
				var certificateByRLC: [RevocationLocation] = []
				for kidWithTypes in keyIdentifiersWithTypes {
					let kid = kidWithTypes.kid
					guard let certificates = filteredGroupedCertificates[kid] else {
						Log.info("no matching certificates found, nothing to do for that kid")
						continue
					}

					let kidTypes = kidWithTypes.types
					for certificate in certificates {
						for type in kidTypes {
							guard let hash = certificate.hash(by: type) else {
								Log.error("Missing hash value")
								continue
							}
							certificateByRLC.insert(
								coordinate: RevocationCoordinate(hash: hash),
								kid: kid,
								type: type,
								certificate: certificate
							)
						}
					}
				}
				certificateByRLC.sort { lhs, rhs in
					lhs.type < rhs.type
				}

				DispatchQueue.global().async {
					self.updateKidType(certificateByRLC) { result in
						switch result {
						case .success:
							completion(.success(()))
						case .failure(let error):
							completion(.failure(error))
						}
					}
				}
			}

		}
	}

	// MARK: - Public

	// MARK: - Internal

	enum RevocationProviderError: Error {
		case internalError
		case chunkUpdateError
		case restError(ServiceError<KIDListResource.CustomError>)
	}

	// MARK: - Private

	private struct KidWithTypes {
		let kid: String
		let types: [String]
	}

	private let restService: RestServiceProviding
	private let signatureVerifier: SignatureVerification

	private func updateKidType(
		_ revocationLocations: [RevocationLocation],
		completion: @escaping(Result<Void, RevocationProviderError>) -> Void
	) {

		let outerDispatchGroup = DispatchGroup()
		var revokedCertificateHashes: [String] = []
		for revocationLocation in revocationLocations {
			let coordinateHealthCertificates = revocationLocation.certificates.filter { _, certificates in
				let certificateHashes = certificates.compactMap { $0.hash(by: revocationLocation.type) }
				let diff = Set(certificateHashes).subtracting(Set(revokedCertificateHashes))
				return !diff.isEmpty
			}

			if coordinateHealthCertificates.isEmpty {
				continue
			}

			// 1 update KID Types
			outerDispatchGroup.enter()
			updateKidTypeIndex(kid: revocationLocation.keyIdentifier, hashType: revocationLocation.type) { [weak self] coordinates in
				defer {
					outerDispatchGroup.leave()
				}
				guard let self = self else {
					Log.error("Failed to get strong self")
					completion(.failure(.internalError))
					return
				}

				// 2 filter for RLC
				let affectedCoordinateHealthCertificates = coordinateHealthCertificates.filter { key, _ in
					coordinates.contains(key)
				}
				// 3 update KID Type chunk
				affectedCoordinateHealthCertificates.forEach { coordinate, _ in
					let innerDispatchGroup = DispatchGroup()
					innerDispatchGroup.enter()
					let resource = KIDTypeChunkResource(
						kid: revocationLocation.keyIdentifier,
						hashType: revocationLocation.type,
						x: coordinate.x,
						y: coordinate.y
					)
					self.restService.load(resource) { result in
						defer {
							innerDispatchGroup.leave()
						}
						switch result {
						case .success(let kidChunk):
							// 4 remove all certificates with matching hash
							revokedCertificateHashes.append(contentsOf: kidChunk.hashes.map { $0.toHexString() })
						case .failure(let error):
							Log.error("failed to update kid x y chunk", error: error)
						}
					}
					innerDispatchGroup.wait()
				}
			}
			outerDispatchGroup.wait()
		}
		completion(.success(()))
	}

	private func updateKidTypeIndex(
		kid: String,
		hashType: String,
		completion: @escaping([RevocationCoordinate]) -> Void
	) {
		let resource = KIDTypeIndexResource(kid: kid, hashType: hashType)
		restService.load(resource) { result in
			switch result {
			case .success(let kidTypeIndices):
				completion(
					kidTypeIndices.items.flatMap({ item in
						item.y.map { y in
							RevocationCoordinate(
								x: item.x.toHexString(),
								y: y.toHexString()
							)
						}
					})
				)
			case .failure(let error):
				Log.error("Failed to load kid type indices", error: error)
			}
		}
	}

}

extension HealthCertificate {

	func hash(by type: String) -> String? {
		switch type {
		case "0a":
			return revocationEntries.signature
		case "0b":
			return revocationEntries.uci
		case "0c":
			return revocationEntries.countryCodeUCI
		default:
			return nil
		}
	}
}

private extension Array where Element == RevocationLocation {

	mutating func insert(coordinate: RevocationCoordinate, kid: String, type: String, certificate: HealthCertificate) {

		// lookup or create entry
		guard let entry = first(where: { rlc in
			rlc.keyIdentifier == kid && rlc.type == type
		}) else {
			// no entry found create a new one and add
			append(
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
		replace(entry, with: updatedEntry)
	}
}
