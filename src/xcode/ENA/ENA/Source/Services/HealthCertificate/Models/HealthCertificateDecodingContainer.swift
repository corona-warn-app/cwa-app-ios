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
	let didShowInvalidNotification: Bool?
	let didShowBlockedNotification: Bool?
	let isNew: Bool?
	let isValidityStateNew: Bool?
	let revocationEntries: HealthCertificateRevocationEntries?
}

class DecodingFailedHealthCertificate: Codable, Equatable {

	// MARK: - Init

	init(
		base45: Base45,
		validityState: HealthCertificateValidityState,
		didShowInvalidNotification: Bool,
		didShowBlockedNotification: Bool,
		isNew: Bool,
		isValidityStateNew: Bool,
		revocationEntries: HealthCertificateRevocationEntries?,
		error: Error?
	) {
		self.base45 = base45
		self.validityState = validityState
		self.didShowInvalidNotification = didShowInvalidNotification
		self.didShowBlockedNotification = didShowBlockedNotification
		self.isNew = isNew
		self.isValidityStateNew = isValidityStateNew
		self.revocationEntries = revocationEntries
		self.error = error
	}

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case base45
		case validityState
		case didShowInvalidNotification
		case didShowBlockedNotification
		case isNew
		case isValidityStateNew
		case revocationEntries
		case error
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		base45 = try container.decode(Base45.self, forKey: .base45)
		validityState = try container.decode(HealthCertificateValidityState.self, forKey: .validityState)
		didShowInvalidNotification = try container.decode(Bool.self, forKey: .didShowInvalidNotification)
		didShowBlockedNotification = try container.decode(Bool.self, forKey: .didShowBlockedNotification)
		isNew = try container.decode(Bool.self, forKey: .isNew)
		isValidityStateNew = try container.decode(Bool.self, forKey: .isValidityStateNew)
		revocationEntries = try container.decodeIfPresent(HealthCertificateRevocationEntries.self, forKey: .revocationEntries)
		error = nil
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(base45, forKey: .base45)
		try container.encode(validityState, forKey: .validityState)
		try container.encode(didShowInvalidNotification, forKey: .didShowInvalidNotification)
		try container.encode(didShowBlockedNotification, forKey: .didShowBlockedNotification)
		try container.encode(isNew, forKey: .isNew)
		try container.encode(isValidityStateNew, forKey: .isValidityStateNew)
		try container.encode(revocationEntries, forKey: .revocationEntries)
	}

	// MARK: - Protocol Equatable

	static func == (lhs: DecodingFailedHealthCertificate, rhs: DecodingFailedHealthCertificate) -> Bool {
		lhs.base45 == rhs.base45
	}

	// MARK: - Internal

	let base45: Base45
	let validityState: HealthCertificateValidityState
	let didShowInvalidNotification: Bool
	let didShowBlockedNotification: Bool
	let isNew: Bool
	let isValidityStateNew: Bool
	let revocationEntries: HealthCertificateRevocationEntries?
	var error: Error?

}
