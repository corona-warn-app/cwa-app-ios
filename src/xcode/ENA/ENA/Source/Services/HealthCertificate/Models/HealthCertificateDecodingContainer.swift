//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

/// Instead of decoding the array of `HealthCertificate`s from the store directly, this intermediate data structure is used.
/// It allows to decode each `HealthCertificate` without all the CBOR overhead that could potentially be failing and thereby
/// be destroying all instances at once, as the decoding of the whole array fails. Using this
/// `HealthCertificateDecodingContainer` allows us to just remove the failed certificates and keep the successfully
/// CBOR decoded certificates around.
final class HealthCertificateDecodingContainer: Codable {

	let base45: Base45
	let validityState: HealthCertificateValidityState?

	var healthCertificate: HealthCertificate? {
		try? HealthCertificate(base45: base45, validityState: validityState ?? .valid)
	}

}
