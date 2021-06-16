////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

struct HealthCertificate: Codable, Equatable, Comparable {

	// MARK: - Init

	init(base45: Base45) throws {
		// Ensure the data will be decodable on the fly later on, even though we don't store the decoded data
		if case .failure(let error) = DigitalGreenCertificateAccess().extractCBORWebTokenHeader(from: base45) {
			Log.error("Failed to decode header of health certificate with error", log: .vaccination, error: error)
			throw error
		}

		if case .failure(let error) = DigitalGreenCertificateAccess().extractDigitalGreenCertificate(from: base45) {
			Log.error("Failed to decode health certificate with error", log: .vaccination, error: error)
			throw error
		}

		self.base45 = base45
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

		fatalError("Unsupported certificates are not added in the first place")
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

	// MARK: - Private

	private var cborWebTokenHeader: CBORWebTokenHeader {
		let result = DigitalGreenCertificateAccess().extractCBORWebTokenHeader(from: base45)

		switch result {
		case .success(let cborWebTokenHeader):
			return cborWebTokenHeader
		case .failure(let error):
			Log.error("Failed to decode header of health certificate with error", log: .vaccination, error: error)
			fatalError("Decoding the cborWebTokenHeader failed even though decodability was checked at initialization.")
		}
	}

	private var digitalGreenCertificate: DigitalGreenCertificate {
		let result = DigitalGreenCertificateAccess().extractDigitalGreenCertificate(from: base45)

		switch result {
		case .success(let digitalGreenCertificate):
			return digitalGreenCertificate
		case .failure(let error):
			Log.error("Failed to decode health certificate with error", log: .vaccination, error: error)
			fatalError("Decoding the digitalGreenCertificate failed even though decodability was checked at initialization.")
		}
	}

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

}
