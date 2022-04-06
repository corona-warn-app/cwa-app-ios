//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

struct HealthCertificateRevocationEntries: Codable {
	
	let uci: String
	let countryCodeUCI: String
	let signature: String
	
	init(
		certificate: DigitalCovidCertificate,
		header: CBORWebTokenHeader,
		signature: Data,
		algorithm: DCCSecKeyAlgorithm
	) {
		
		// Calculate hash: the hash shall be calculated as the SHA-256 of ci.
		// Determine revocationEntry: the revocationEntry shall be set to the hex-encoded representation of the first 16 bytes of the hash.
		self.uci = Data((
			certificate.uniqueCertificateIdentifier
				.data(using: .utf8)?
				.sha256(enforceFallback: false)
				.bytes[0...15]) ?? []
			).toHexString()
		
		// Calculate hash: the hash shall be calculated as the SHA-256 of concatenated string of iss and ci.
		// Determine revocationEntry: the revocationEntry shall be set to the hex-encoded representation of the first 16 bytes of the hash.
		self.countryCodeUCI = Data((
			(header.issuer + certificate.uniqueCertificateIdentifier)
				.data(using: .utf8)?
				.sha256(enforceFallback: false)
				.bytes[0...15]) ?? []
			).toHexString()
		
		// If alg equals -7 (for ES256), byteSequenceToHash shall be set to the first half of the byte sequence of signature (e.g. if signature has 42 bytes, the first 21 bytes shall be taken).
		// For any other value of alg, byteSequenceToHash shall be set to signature
		let byteSequenceToHash = algorithm == .ES256 ?
		Data(signature.bytes[0...signature.count / 2 - 1]) :
		signature
		
		// Calculate hash: the hash shall be calculated as the SHA-256 of byteSequenceToHash.
		// Determine revocationEntry: the revocationEntry shall be set to the hex-encoded representation of the first 16 bytes of the hash.
		self.signature = Data(byteSequenceToHash
			.sha256(enforceFallback: false)
			.bytes[0...15])
			.toHexString()
	}
}
