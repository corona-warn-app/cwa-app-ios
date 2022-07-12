//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftUI

protocol RevocationProviding {
	func updateCache(with certificates: [HealthCertificate], completion: @escaping (Result<[HealthCertificate], RevocationProviderError>) -> Void)
	func isRevokedFromRevocationList(healthCertificate: HealthCertificate) -> Bool
}

enum RevocationProviderError: Error {
	case requestFailed
}

final class RevocationProvider: RevocationProviding {

	// MARK: - Init

	init(
		restService: RestServiceProviding,
		store: RevokedCertificatesStoring,
		signatureVerifier: SignatureVerification = SignatureVerifier()
	) {
		self.restService = restService
		self.store = store
		self.signatureVerifier = signatureVerifier
	}

	// MARK: - Protocol RevocationProviding

	func updateCache(
		with certificates: [HealthCertificate],
		completion: @escaping (Result<[HealthCertificate], RevocationProviderError>) -> Void
	) {
		// 1. Filter by certificate type
		let filteredCertificates = certificates.filter { certificate in
			(certificate.type == .vaccination ||
			 certificate.type == .recovery)
		}

		// 2. group certificates by kid
		let groupedCertificates = Dictionary(grouping: filteredCertificates) {
			$0.hexKeyIdentifier
		}

		// 3. Update KID List
		let resource = KIDListResource(signatureVerifier: signatureVerifier)
		restService.load(resource) { [weak self] result in
			guard let self = self else {
				Log.error("Failed to get strong self")
				return
			}

			switch result {
			case .failure(let error):
				Log.error("failed to update kid list", error: error)
				completion(.failure(.requestFailed))
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

				self.updateKidType(certificateByRLC) { result in
					switch result {
					case .success(let revokedCertificates):
						self.store.revokedCertificates = revokedCertificates.map { $0.base45 }
						completion(.success(revokedCertificates))
					case .failure(let error):
						completion(.failure(error))
					}
				}
			}
		}
	}

	func isRevokedFromRevocationList(healthCertificate: HealthCertificate) -> Bool {
		store.revokedCertificates
			.contains(healthCertificate.base45)
	}

	// MARK: - Internal

#if !RELEASE
	// Needed for dev menu force updates.
	static let keyForceUpdateRevocationList = "keyForceUpdateRevocationList"
#endif

	// MARK: - Private

	private struct KidWithTypes {
		let kid: String
		let types: [String]
	}

	private let restService: RestServiceProviding
	private let store: RevokedCertificatesStoring
	private let signatureVerifier: SignatureVerification

	private func updateKidType(
		_ revocationLocations: [RevocationLocation],
		completion: @escaping(Result<[HealthCertificate], RevocationProviderError>) -> Void
	) {
		// Ensure that dispatch group does not block main thread
		DispatchQueue.global().async {
			var revokedCertificates = Set<HealthCertificate>()
			var errorOccurred = false
			for revocationLocation in revocationLocations {
				let outerDispatchGroup = DispatchGroup()
				outerDispatchGroup.enter()
				let coordinateHealthCertificates = revocationLocation.certificates.filter { _, certificates in
					let diff = Set(certificates).subtracting(Set(revokedCertificates))
					return !diff.isEmpty
				}

				if coordinateHealthCertificates.isEmpty {
					continue
				}

				// 1 update KID Types
				self.updateKidTypeIndex(kid: revocationLocation.keyIdentifier, hashType: revocationLocation.type) { [weak self] result in
					guard case .success(let coordinates) = result else {
						errorOccurred = true
						outerDispatchGroup.leave()
						return
					}

					// Ensure that dispatch group does not block main thread
					DispatchQueue.global().async {
						defer {
							outerDispatchGroup.leave()
						}
						guard let self = self else {
							Log.error("Failed to get strong self")
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
									// 4 collect all certificates with matching hash to skip them in later loop iterations
									let matchingCertificates = revocationLocation.certificates
										.flatMap {
											$0.value
										}
										.filter { certificate in
											guard let hashString = certificate.hash(by: revocationLocation.type)?.dataWithHexString() else {
												return false
											}

											return kidChunk.hashes.contains(hashString)
										}
									revokedCertificates.formUnion(matchingCertificates)
								case .failure(let error):
									errorOccurred = true
									Log.error("failed to update kid x y chunk", error: error)
								}
							}
							innerDispatchGroup.wait()
						}
					}
				}
				outerDispatchGroup.wait()
			}

			if errorOccurred {
				completion(.failure(.requestFailed))
			} else {
				completion(.success(Array(revokedCertificates)))
			}
		}
	}

	private func updateKidTypeIndex(
		kid: String,
		hashType: String,
		completion: @escaping(Result<[RevocationCoordinate], RevocationProviderError>) -> Void
	) {
		let resource = KIDTypeIndexResource(kid: kid, hashType: hashType)
		restService.load(resource) { result in
			switch result {
			case .success(let kidTypeIndices):
				completion(
					.success(
						kidTypeIndices.items.flatMap({ item in
							item.y.map { y in
								RevocationCoordinate(
									x: item.x.toHexString(),
									y: y.toHexString()
								)
							}
						})
					)
				)
			case .failure(let error):
				Log.error("Failed to load kid type indices", error: error)
				completion(.failure(.requestFailed))
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
