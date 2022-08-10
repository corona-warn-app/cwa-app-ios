////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

final class HealthCertificate: Codable, Equatable, Comparable, RecycleBinIdentifiable, Hashable {

	// MARK: - Init

	init(
		base45: Base45,
		validityState: HealthCertificateValidityState = .valid,
		didShowInvalidNotification: Bool = false,
		didShowBlockedNotification: Bool = false,
		didShowRevokedNotification: Bool = false,
		isNew: Bool = false,
		isValidityStateNew: Bool = false,
		revocationEntries: HealthCertificateRevocationEntries? = nil
	) throws {
		self.base45 = base45
		self.validityState = validityState
		self.didShowInvalidNotification = didShowInvalidNotification
		self.didShowBlockedNotification = didShowBlockedNotification
		self.didShowRevokedNotification = didShowRevokedNotification
		self.isNew = isNew
		self.isValidityStateNew = isValidityStateNew

		let certificateComponents = try Self.extractCertificateComponents(from: base45)
		cborWebTokenHeader = certificateComponents.header
		digitalCovidCertificate = certificateComponents.certificate
		keyIdentifier = certificateComponents.keyIdentifier
		
		if let revocationEntries = revocationEntries {
			self.revocationEntries = revocationEntries
		} else {
			self.revocationEntries = HealthCertificateRevocationEntries(
				certificate: certificateComponents.certificate,
				header: certificateComponents.header,
				signature: certificateComponents.signature,
				algorithm: certificateComponents.algorithm
			)
		}

	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		base45 = try container.decode(Base45.self, forKey: .base45)
		validityState = try container.decodeIfPresent(HealthCertificateValidityState.self, forKey: .validityState) ?? .valid
		isValidityStateNew = try container.decodeIfPresent(Bool.self, forKey: .isValidityStateNew) ?? false
		isNew = try container.decodeIfPresent(Bool.self, forKey: .isNew) ?? false
		didShowInvalidNotification = try container.decodeIfPresent(Bool.self, forKey: .didShowInvalidNotification) ?? false
		didShowBlockedNotification = try container.decodeIfPresent(Bool.self, forKey: .didShowBlockedNotification) ?? false
		didShowRevokedNotification = try container.decodeIfPresent(Bool.self, forKey: .didShowRevokedNotification) ?? false
		
		let certificateComponents = try Self.extractCertificateComponents(from: base45)
		cborWebTokenHeader = certificateComponents.header
		digitalCovidCertificate = certificateComponents.certificate
		keyIdentifier = certificateComponents.keyIdentifier
		
		if let revocationEntries = try container.decodeIfPresent(HealthCertificateRevocationEntries.self, forKey: .revocationEntries) {
			self.revocationEntries = revocationEntries
		} else {
			self.revocationEntries = HealthCertificateRevocationEntries(
				certificate: certificateComponents.certificate,
				header: certificateComponents.header,
				signature: certificateComponents.signature,
				algorithm: certificateComponents.algorithm
			)
		}
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
		case didShowBlockedNotification
		case didShowRevokedNotification
		case revocationEntries
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(base45, forKey: .base45)
		try container.encode(validityState, forKey: .validityState)
		try container.encode(isNew, forKey: .isNew)
		try container.encode(isValidityStateNew, forKey: .isValidityStateNew)
		try container.encode(didShowInvalidNotification, forKey: .didShowInvalidNotification)
		try container.encode(didShowBlockedNotification, forKey: .didShowBlockedNotification)
		try container.encode(didShowRevokedNotification, forKey: .didShowRevokedNotification)
		try container.encode(revocationEntries, forKey: .revocationEntries)
	}

	// MARK: - Protocol Equatable

	static func == (lhs: HealthCertificate, rhs: HealthCertificate) -> Bool {
		lhs === rhs
	}

	// MARK: - Protocol Comparable

	static func < (lhs: HealthCertificate, rhs: HealthCertificate) -> Bool {
		if let lhsDate = lhs.sortDate, let rhsDate = rhs.sortDate {
			return (lhsDate, lhs.cborWebTokenHeader.issuedAt) < (rhsDate, rhs.cborWebTokenHeader.issuedAt)
		}
		return false
	}

	// MARK: - Protocol Hashable

	func hash(into hasher: inout Hasher) {
		hasher.combine(base45)
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
	let keyIdentifier: String
	let revocationEntries: HealthCertificateRevocationEntries

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

	@DidSetPublished var didShowBlockedNotification: Bool {
		didSet {
			if didShowBlockedNotification != oldValue {
				objectDidChange.send(self)
			}
		}
	}

	@DidSetPublished var didShowRevokedNotification: Bool {
		didSet {
			if didShowRevokedNotification != oldValue {
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

	var hexKeyIdentifier: String {
		Data(base64Encoded: keyIdentifier)?.toHexString() ?? ""
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

	/// On test certificates only `.valid`, `.invalid`,  `.blocked`, and `.revoked` states are shown, the `.expiringSoon` and `.expired` states are considered valid as well
	var isConsideredValid: Bool {
		validityState == .valid || type == .test && (validityState == .expiringSoon || validityState == .expired)
	}

	var validityStateIsConsideredNewsworthy: Bool {
		switch validityState {
		case .valid:
			return false
		case .invalid, .blocked, .revoked, .expired, .expiringSoon:
			return true
		}
	}

	var isValidityStateConsiderableForExporting: Bool {
		switch validityState {
		case .valid, .expiringSoon, .expired, .invalid:
			return true
		case .blocked, .revoked:
			return false
		}
	}
	
	var isTypeSpecificCriteriaValid: Bool {
		switch entry {
		case .vaccination, .recovery:
			return true
		case .test:
			guard let ageInHours = ageInHours else {
				return false
			}
			return ageInHours <= 72
		}
	}
	
	lazy var uniqueCertificateIdentifierChunks: [String] = uniqueCertificateIdentifier
			.dropPrefix("URN:UVCI:")
			.components(separatedBy: CharacterSet(charactersIn: "/#:"))

	lazy var sortDate: Date? = {
		switch entry {
		case .vaccination(let vaccinationEntry):
			return vaccinationEntry.localVaccinationDate
		case .test(let testEntry):
			return testEntry.sampleCollectionDate
		case .recovery(let recoveryEntry):
			return recoveryEntry.localDateOfFirstPositiveNAAResult
		}
	}()
		
	func belongsToSamePerson(_ other: HealthCertificate) -> Bool {
		// The sanitized dateOfBirth attributes are the same strings
		guard self.trimmedDateOfBirth == other.trimmedDateOfBirth else {
			return false
		}
		
		// The intersection/overlap of the name components of sanitized familyNameComponents and otherFamilyNameComponents has at least one element, and
		// the intersection/overlap of the name components of sanitized givenNameCompontents and otherGivenNameCompontents has at least one element
		// or both are empty sets (givenName is an optional field)
		let hasGivenNameIntersection: Bool
		if givenNameComponents.isEmpty && other.givenNameComponents.isEmpty {
			hasGivenNameIntersection = true
		} else {
			hasGivenNameIntersection = givenNameComponents.intersection(other.givenNameComponents).isNotEmpty
		}
		
		let hasFamilyNameIntersection: Bool
		if familyNameComponents.isEmpty && other.familyNameComponents.isEmpty {
			hasFamilyNameIntersection = true
		} else {
			hasFamilyNameIntersection = familyNameComponents.intersection(other.familyNameComponents).isNotEmpty
		}
		let hasNameIntersections = hasGivenNameIntersection && hasFamilyNameIntersection
		
		// The intersection/overlap of the name components of sanitized familyNameComponents and otherGivenNameCompontents has at least one element, and
		// the intersection/overlap of the name components of sanitized givenNameCompontents and otherFamilyNameComponents has at least one element
		// This covers scenarios where familyName and givenName were swapped.
		let hasCrossIntersection_FamilyName_GivenName = familyNameComponents.intersection(other.givenNameComponents).isNotEmpty
		let hasCrossIntersection_GivenName_FamilyName = givenNameComponents.intersection(other.familyNameComponents).isNotEmpty
		
		let hasCrossNameIntersectionWithOneEmptyName: Bool
		if givenNameComponents.isEmpty && other.familyNameComponents.isEmpty {
			hasCrossNameIntersectionWithOneEmptyName = familyNameComponents.intersection(other.givenNameComponents).isNotEmpty
		} else if familyNameComponents.isEmpty && other.givenNameComponents.isEmpty {
			hasCrossNameIntersectionWithOneEmptyName = givenNameComponents.intersection(other.familyNameComponents).isNotEmpty
		} else {
			hasCrossNameIntersectionWithOneEmptyName = false
		}
		let hasCrossNameIntersections = hasCrossNameIntersectionWithOneEmptyName || (hasCrossIntersection_FamilyName_GivenName && hasCrossIntersection_GivenName_FamilyName)
		
		return hasNameIntersections || hasCrossNameIntersections
	}

	// MARK: - Private

	private lazy var givenNameComponents = Set<String>(name.givenNameGroupingComponents)
	private lazy var familyNameComponents = Set<String>(name.familyNameGroupingComponents)
	private lazy var trimmedDateOfBirth: String = digitalCovidCertificate.dateOfBirth
		.trimmingCharacters(in: .whitespaces)

	private static func extractCertificateComponents(from base45: Base45) throws -> DigitalCovidCertificateComponents {
		let componentsResult = DigitalCovidCertificateAccess().extractCertificateComponents(from: base45)
		
		switch componentsResult {
		case .success(let components):
			return components
		case .failure(let error):
			Log.error("Failed to decode health certificate components with error", log: .vaccination, error: error)
			throw error
		}
	}

}
