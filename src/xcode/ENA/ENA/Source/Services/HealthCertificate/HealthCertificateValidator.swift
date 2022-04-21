//
// 🦠 Corona-Warn-App
//

import Foundation

protocol HealthCertificateValidating {
	func isRevokedFromRevocationList(healthCertificate: HealthCertificate) -> Bool
}

class HealthCertificateValidator: HealthCertificateValidating {
	
	// MARK: - Init

	init(
		restServiceProvider: RestServiceProviding
	) {
		self.restServiceProvider = restServiceProvider
	}
	
	// MARK: - Internal

	func isRevokedFromRevocationList(healthCertificate: HealthCertificate) -> Bool {
		// Check against cached revocation list: the DCC shall be checked against the revocation list.
		
		// `0a` for `SIGNATURE`
		let revocationChunkMatchesFor0a = validateChunks(
			kid: healthCertificate.keyIdentifier,
			hashType: "0a",
			hash: healthCertificate.revocationEntries.signature
		)
		
		// `0b` for `UCI`
		let revocationChunkMatchesFor0b = validateChunks(
			kid: healthCertificate.keyIdentifier,
			hashType: "0b",
			hash: healthCertificate.revocationEntries.uci
		)
		
		// `0c` for `COUNTRYCODEUCI`
		let revocationChunkMatchesFor0c = validateChunks(
			kid: healthCertificate.keyIdentifier,
			hashType: "0c",
			hash: healthCertificate.revocationEntries.countryCodeUCI
		)
		
		return revocationChunkMatchesFor0a || revocationChunkMatchesFor0b || revocationChunkMatchesFor0c
	}
	
	// MARK: - Private

	private func validateChunks(kid: String, hashType: String, hash: String) -> Bool {
		let coordinate = RevocationCoordinate(
			hash: hash
		)
		let resource = KIDTypeChunkResource(
			kid: kid,
			hashType: hashType,
			x: coordinate.x,
			y: coordinate.y
		)
		let cachedResult = restServiceProvider.cached(resource)
		
		if case .success(let revocationChunk) = cachedResult {
			let revocationChunkMatches = revocationChunk.hashes.contains { chunkHash in
				chunkHash == hash.dataWithHexString()
			}
			if revocationChunkMatches {
				return true
			}
		}
		
		return false
	}
	
	private let restServiceProvider: RestServiceProviding
}
