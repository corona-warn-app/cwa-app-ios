////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

final class HealthCertificate: Codable, Equatable, Comparable, RecycleBinIdentifiable {

	// MARK: - Init

	init(
		base45: Base45,
		validityState: HealthCertificateValidityState = .valid,
		didShowInvalidNotification: Bool = false,
		isNew: Bool = false,
		isValidityStateNew: Bool = false
	) throws {
		self.base45 = base45
		self.validityState = validityState
		self.didShowInvalidNotification = didShowInvalidNotification
		self.isNew = isNew
		self.isValidityStateNew = isValidityStateNew

		cborWebTokenHeader = try Self.extractCBORWebTokenHeader(from: base45)
		digitalCovidCertificate = try Self.extractDigitalCovidCertificate(from: base45)
		keyIdentifier = Self.extractKeyIdentifier(from: base45)
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		base45 = try container.decode(Base45.self, forKey: .base45)
		validityState = try container.decodeIfPresent(HealthCertificateValidityState.self, forKey: .validityState) ?? .valid
		isValidityStateNew = try container.decodeIfPresent(Bool.self, forKey: .isValidityStateNew) ?? false
		isNew = try container.decodeIfPresent(Bool.self, forKey: .isNew) ?? false
		didShowInvalidNotification = try container.decodeIfPresent(Bool.self, forKey: .didShowInvalidNotification) ?? false

		cborWebTokenHeader = try Self.extractCBORWebTokenHeader(from: base45)
		digitalCovidCertificate = try Self.extractDigitalCovidCertificate(from: base45)
		keyIdentifier = Self.extractKeyIdentifier(from: base45)
	}

	// MARK: - Protocol RecycleBinIdentifiable

	var recycleBinIdentifier: String {
		return base45
	}

	// MARK: - Protocol Encodable

	// Decoding is handled by the HealthCertificateDecodingContainer!

	enum CodingKeys: String, CodingKey {
		case base45
		case validityState
		case isNew
		case isValidityStateNew
		case didShowInvalidNotification
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(base45, forKey: .base45)
		try container.encode(validityState, forKey: .validityState)
		try container.encode(isNew, forKey: .isNew)
		try container.encode(isValidityStateNew, forKey: .isValidityStateNew)
		try container.encode(didShowInvalidNotification, forKey: .didShowInvalidNotification)
	}

	// MARK: - Protocol Equatable

	static func == (lhs: HealthCertificate, rhs: HealthCertificate) -> Bool {
		lhs.base45 == rhs.base45 &&
		lhs.validityState == rhs.validityState &&
		lhs.isNew == rhs.isNew &&
		lhs.isValidityStateNew == rhs.isValidityStateNew &&
		lhs.didShowInvalidNotification == rhs.didShowInvalidNotification
	}

	// MARK: - Protocol Comparable

	static func < (lhs: HealthCertificate, rhs: HealthCertificate) -> Bool {
		if let lhsDate = lhs.sortDate, let rhsDate = rhs.sortDate {
			return lhsDate < rhsDate
		}

		return false
	}

	// MARK: - Internal
	
	enum CertificateType {
		case vaccination
		case test
		case recovery
	}

	enum CertificateEntry {
		case vaccination(VaccinationEntry)
		case test(TestEntry)
		case recovery(RecoveryEntry)
	}

	let base45: Base45
	let cborWebTokenHeader: CBORWebTokenHeader
	let digitalCovidCertificate: DigitalCovidCertificate
	let keyIdentifier: String?

	let objectDidChange = OpenCombine.PassthroughSubject<HealthCertificate, Never>()

	@DidSetPublished var validityState: HealthCertificateValidityState {
		didSet {
			if validityState != oldValue {
				objectDidChange.send(self)
			}
		}
	}

	@DidSetPublished var didShowInvalidNotification: Bool {
		didSet {
			if didShowInvalidNotification != oldValue {
				objectDidChange.send(self)
			}
		}
	}
				
	@DidSetPublished var isNew: Bool {
		didSet {
			if isNew != oldValue {
				objectDidChange.send(self)
			}
		}
	}

	@DidSetPublished var isValidityStateNew: Bool {
		didSet {
			if isValidityStateNew != oldValue {
				objectDidChange.send(self)
			}
		}
	}
	
	var version: String {
		digitalCovidCertificate.version
	}

	var name: HealthCertificateToolkit.Name {
		digitalCovidCertificate.name
	}

	var dateOfBirth: String {
		digitalCovidCertificate.dateOfBirth
	}

	var dateOfBirthDate: Date? {
		return ISO8601DateFormatter.justLocalDateFormatter.date(from: digitalCovidCertificate.dateOfBirth)
	}

	var uniqueCertificateIdentifier: String {
		switch entry {
		case .vaccination(let vaccinationEntry):
			return vaccinationEntry.uniqueCertificateIdentifier
		case .test(let testEntry):
			return testEntry.uniqueCertificateIdentifier
		case .recovery(let recoveryEntry):
			return recoveryEntry.uniqueCertificateIdentifier
		}
	}

	var vaccinationEntry: VaccinationEntry? {
		digitalCovidCertificate.vaccinationEntries?.first
	}

	var testEntry: TestEntry? {
		digitalCovidCertificate.testEntries?.first
	}

	var recoveryEntry: RecoveryEntry? {
		digitalCovidCertificate.recoveryEntries?.first
	}

	var hasTooManyEntries: Bool {
		let entryCount = [
			digitalCovidCertificate.vaccinationEntries?.count ?? 0,
			digitalCovidCertificate.testEntries?.count ?? 0,
			digitalCovidCertificate.recoveryEntries?.count ?? 0
		].reduce(0, +)

		return entryCount != 1
	}

	var type: CertificateType {
		switch entry {
		case .vaccination:
			return .vaccination
		case .test:
			return .test
		case .recovery:
			return .recovery
		}
	}

	var entry: CertificateEntry {
		if let vaccinationEntry = vaccinationEntry {
			return .vaccination(vaccinationEntry)
		} else if let testEntry = testEntry {
			return .test(testEntry)
		} else if let recoveryEntry = recoveryEntry {
			return .recovery(recoveryEntry)
		}

		fatalError("Unsupported certificates are not added in the first place")
	}

	var expirationDate: Date {
		return cborWebTokenHeader.expirationTime
	}

	var ageInHours: Int? {
		guard let sortDate = sortDate else {
			return nil
		}

		return Calendar.current.dateComponents([.hour], from: sortDate, to: Date()).hour
	}

	var ageInDays: Int? {
		guard let sortDate = sortDate else {
			return nil
		}

		return Calendar.current.dateComponents([.day], from: sortDate, to: Date()).day
	}

	var isUsable: Bool {
		validityState == .valid || validityState == .expiringSoon || (type == .test && validityState == .expired)
	}

	/// On test certificates only `.valid`, `.invalid`, and `.blocked` states are shown, the `.expiringSoon` and `.expired` states are considered valid as well
	var isConsideredValid: Bool {
		validityState == .valid || type == .test && (validityState == .expiringSoon || validityState == .expired)
	}

	var uniqueCertificateIdentifierChunks: [String] {
		uniqueCertificateIdentifier
			.dropPrefix("URN:UVCI:")
			.components(separatedBy: CharacterSet(charactersIn: "/#:"))
	}

	func isBlocked(by blockedIdentifierChunks: [SAP_Internal_V2_DGCBlockedUVCIChunk]) -> Bool {
		blockedIdentifierChunks.contains {
			/// Skip if at least on index would be out of bounds
			guard $0.indices.allSatisfy({ $0 < uniqueCertificateIdentifierChunks.count }) else {
				return false
			}

			let blockedChunks =	$0.indices
				.map { uniqueCertificateIdentifierChunks[Int($0)] }
				.joined(separator: "/")

			let hash = ENAHasher.sha256(blockedChunks)
			let hashData = Data(base64Encoded: hash)

			return hashData == $0.hash
		}
	}

	// MARK: - Private

	private var sortDate: Date? {
		switch entry {
		case .vaccination(let vaccinationEntry):
			return vaccinationEntry.localVaccinationDate
		case .test(let testEntry):
			return testEntry.sampleCollectionDate
		case .recovery(let recoveryEntry):
			return recoveryEntry.localCertificateValidityStartDate
		}
	}

	private static func extractCBORWebTokenHeader(from base45: Base45) throws -> CBORWebTokenHeader {
		let webTokenHeaderResult = DigitalCovidCertificateAccess().extractCBORWebTokenHeader(from: base45)

		switch webTokenHeaderResult {
		case .success(let cborWebTokenHeader):
			return cborWebTokenHeader
		case .failure(let error):
			Log.error("Failed to decode header of health certificate with error", log: .vaccination, error: error)
			throw error
		}
	}

	private static func extractDigitalCovidCertificate(from base45: Base45) throws -> DigitalCovidCertificate {
		let certificateResult = DigitalCovidCertificateAccess().extractDigitalCovidCertificate(from: base45)

		switch certificateResult {
		case .success(let digitalCovidCertificate):
			return digitalCovidCertificate
		case .failure(let error):
			Log.error("Failed to decode health certificate with error", log: .vaccination, error: error)
			throw error
		}
	}

	private static func extractKeyIdentifier(from base45: Base45) -> Base64? {
		let certificateResult = DigitalCovidCertificateAccess().extractKeyIdentifier(from: base45)

		switch certificateResult {
		case .success(let keyIdentifier):
			return keyIdentifier
		case .failure(let error):
			Log.error("Failed to decode key identifier (kid) with error", log: .vaccination, error: error)
			return nil
		}
	}
}
