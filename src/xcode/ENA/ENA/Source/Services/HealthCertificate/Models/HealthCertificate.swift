////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

struct HealthCertificate: Codable, Equatable, Comparable {

	// MARK: - Init

	init(base45: Base45) throws {
		self.base45 = base45
		self.cborWebTokenHeader = Self.extractCBORWebTokenHeader(from: base45)
		self.digitalGreenCertificate = Self.extractDigitalGreenCertificate(from: base45)
	}

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case base45
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		base45 = try container.decode(Base45.self, forKey: .base45)

		self.cborWebTokenHeader = Self.extractCBORWebTokenHeader(from: base45)
		self.digitalGreenCertificate = Self.extractDigitalGreenCertificate(from: base45)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(base45, forKey: .base45)
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

	var version: String {
		digitalGreenCertificate.version
	}

	var name: HealthCertificateToolkit.Name {
		digitalGreenCertificate.name
	}

	var dateOfBirth: String {
		digitalGreenCertificate.dateOfBirth
	}

	var dateOfBirthDate: Date? {
		return ISO8601DateFormatter.justLocalDateFormatter.date(from: digitalGreenCertificate.dateOfBirth)
	}

	var uniqueCertificateIdentifier: String? {
		vaccinationEntry?.uniqueCertificateIdentifier ?? testEntry?.uniqueCertificateIdentifier
	}

	var vaccinationEntry: VaccinationEntry? {
		digitalGreenCertificate.vaccinationEntries?.first
	}

	var testEntry: TestEntry? {
		digitalGreenCertificate.testEntries?.first
	}

	var recoveryEntry: RecoveryEntry? {
		digitalGreenCertificate.recoveryEntries?.first
	}

	var hasTooManyEntries: Bool {
		let entryCount = [
			digitalGreenCertificate.vaccinationEntries?.count ?? 0,
			digitalGreenCertificate.testEntries?.count ?? 0,
			digitalGreenCertificate.recoveryEntries?.count ?? 0
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
		#if DEBUG
		if isUITesting, let localVaccinationDate = vaccinationEntry?.localVaccinationDate {
			return Calendar.current.date(byAdding: .year, value: 1, to: localVaccinationDate) ??
				Date(timeIntervalSince1970: TimeInterval(cborWebTokenHeader.expirationTime))
		}
		#endif

		return Date(timeIntervalSince1970: TimeInterval(cborWebTokenHeader.expirationTime))
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

	// MARK: - Private

	private let cborWebTokenHeader: CBORWebTokenHeader
	private let digitalGreenCertificate: DigitalGreenCertificate

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

	private static func extractCBORWebTokenHeader(from base45: Base45) -> CBORWebTokenHeader {
		let webTokenHeaderResult = DigitalGreenCertificateAccess().extractCBORWebTokenHeader(from: base45)

		switch webTokenHeaderResult {
		case .success(let cborWebTokenHeader):
			return cborWebTokenHeader
		case .failure(let error):
			Log.error("Failed to decode header of health certificate with error", log: .vaccination, error: error)
			fatalError("Decoding the cborWebTokenHeader failed even though decodability was checked at initialization.")
		}
	}

	private static func extractDigitalGreenCertificate(from base45: Base45) -> DigitalGreenCertificate {
		let certificateResult = DigitalGreenCertificateAccess().extractDigitalGreenCertificate(from: base45)

		switch certificateResult {
		case .success(let digitalGreenCertificate):
			return digitalGreenCertificate
		case .failure(let error):
			Log.error("Failed to decode health certificate with error", log: .vaccination, error: error)
			fatalError("Decoding the digitalGreenCertificate failed even though decodability was checked at initialization.")
		}
	}

}
