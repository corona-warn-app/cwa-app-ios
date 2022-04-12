//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import HealthCertificateToolkit

extension XCTestCase {

	enum Base45FakeError: Error {
		case failed
	}

	func base45Fake(
		from digitalCovidCertificate: DigitalCovidCertificate,
		and webTokenHeader: CBORWebTokenHeader = .fake()
	) throws -> Base45 {
		let base45Result = DigitalCovidCertificateFake.makeBase45Fake(
			from: digitalCovidCertificate,
			and: webTokenHeader
		)

		guard case let .success(base45) = base45Result else {
			XCTFail("Could not make fake base45 certificate")
			throw Base45FakeError.failed
		}

		return base45
	}
	
	func recoveryCertificate(
		daysOffset: Int = 0
	) throws -> HealthCertificate {
		let date = Calendar.current.date(byAdding: .day, value: daysOffset, to: Date())
		let recoveryCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [
						RecoveryEntry.fake(
							dateOfFirstPositiveNAAResult: ISO8601DateFormatter.justUTCDateFormatter.string(from: try XCTUnwrap(date))
						)
					]
				)
			),
			validityState: .valid
		)

		return recoveryCertificate
	}
	
	func vaccinationCertificate(
		daysOffset: Int = 0,
		doseNumber: Int = 1,
		totalSeriesOfDoses: Int = 2,
		identifier: String = "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S",
		name: Name = .fake(),
		dateOfBirth: String = "1942-01-01"
	) throws -> HealthCertificate {
		let date = Calendar.current.date(byAdding: .day, value: daysOffset, to: Date())
		let vaccinationEntry = VaccinationEntry.fake(
			doseNumber: doseNumber,
			totalSeriesOfDoses: totalSeriesOfDoses,
			dateOfVaccination: ISO8601DateFormatter.justUTCDateFormatter.string(from: try XCTUnwrap(date)),
			uniqueCertificateIdentifier: identifier
		)

		let firstTestCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: name,
				dateOfBirth: dateOfBirth,
				vaccinationEntries: [
					vaccinationEntry
				]
			)
		)

		return try HealthCertificate(base45: firstTestCertificateBase45)
	}

	func testCertificate(
		daysOffset: Int = 0,
		type: CoronaTestType = .antigen,
		identifier: String = "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A4#S",
		dateOfBirth: String = "1942-01-01"
	) throws -> HealthCertificate {
		let date = Calendar.current.date(byAdding: .day, value: daysOffset, to: Date())
		let testEntry = TestEntry.fake(
			typeOfTest: type == .antigen ? TestEntry.antigenTypeString : TestEntry.pcrTypeString,
			dateTimeOfSampleCollection: ISO8601DateFormatter().string(from: try XCTUnwrap(date)),
			uniqueCertificateIdentifier: identifier
		)

		let firstTestCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				dateOfBirth: dateOfBirth,
				testEntries: [
					testEntry
				]
			)
		)

		return try HealthCertificate(base45: firstTestCertificateBase45)
	}

}
