//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import HealthCertificateToolkit

extension CWATestCase {

	enum MockError: Error {
		case error(String)
	}

	enum VaccinationCertificateType {
		case seriesCompletingOrBooster
		case incomplete
	}

	func recoveryCertificate(
		ageInDays: Int,
		validityState: HealthCertificateValidityState = .valid
	) throws -> HealthCertificate {
		guard let certificateValidityStartDate = Calendar.current.date(byAdding: .day, value: -ageInDays, to: Date()) else {
			throw MockError.error("Could not create date")
		}
		let formattedCertificateValidityStartDate = ISO8601DateFormatter.string(from: certificateValidityStartDate, timeZone: .current, formatOptions: .withFullDate)

		let base45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				recoveryEntries: [
					RecoveryEntry.fake(
						certificateValidFrom: formattedCertificateValidityStartDate
					)
				]
			)
		)

		return try HealthCertificate(base45: base45, validityState: validityState)
	}

	func testCertificate(
		coronaTestType: CoronaTestType,
		ageInHours: Int,
		validityState: HealthCertificateValidityState = .valid
	) throws -> HealthCertificate {
		let typeOfTest: String
		switch coronaTestType {
		case .pcr:
			typeOfTest = TestEntry.pcrTypeString
		case .antigen:
			typeOfTest = TestEntry.antigenTypeString
		}

		guard let sampleCollectionDate = Calendar.current.date(byAdding: .hour, value: -ageInHours, to: Date()) else {
			throw MockError.error("Could not create date")
		}
		let formattedSampleCollectionDate = ISO8601DateFormatter.string(from: sampleCollectionDate, timeZone: .current, formatOptions: .withInternetDateTime)

		let base45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				testEntries: [
					TestEntry.fake(
						typeOfTest: typeOfTest,
						dateTimeOfSampleCollection: formattedSampleCollectionDate
					)
				]
			)
		)

		return try HealthCertificate(base45: base45, validityState: validityState)
	}

	func vaccinationCertificate(
		type: VaccinationCertificateType,
		ageInDays: Int,
		validityState: HealthCertificateValidityState = .valid,
		cborWebTokenHeader: CBORWebTokenHeader = .fake()
	) throws -> HealthCertificate {
		var vaccinations = [(doseNumber: Int, totalSeriesOfDoses: Int)]()

		switch type {
		case .seriesCompletingOrBooster:
			vaccinations = [
				(doseNumber: Int.random(in: 1...9), totalSeriesOfDoses: 1),
				(doseNumber: Int.random(in: 2...9), totalSeriesOfDoses: 2),
				(doseNumber: Int.random(in: 3...9), totalSeriesOfDoses: 3)
			]
		case .incomplete:
			vaccinations = [
				(doseNumber: 1, totalSeriesOfDoses: 2),
				(doseNumber: 1, totalSeriesOfDoses: 3),
				(doseNumber: 2, totalSeriesOfDoses: 3),
				(doseNumber: 1, totalSeriesOfDoses: 4),
				(doseNumber: 2, totalSeriesOfDoses: 4),
				(doseNumber: 3, totalSeriesOfDoses: 4)
			]
		}

		let vaccination = try XCTUnwrap(vaccinations.randomElement())

		guard let vaccinationDate = Calendar.current.date(byAdding: .day, value: -ageInDays, to: Date()) else {
			throw MockError.error("Could not create date")
		}
		let formattedVaccinationDate = ISO8601DateFormatter.string(from: vaccinationDate, timeZone: .current, formatOptions: .withFullDate)

		let base45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				vaccinationEntries: [
					VaccinationEntry.fake(
						doseNumber: vaccination.doseNumber,
						totalSeriesOfDoses: vaccination.totalSeriesOfDoses,
						dateOfVaccination: formattedVaccinationDate
					)
				]
			),
			webTokenHeader: cborWebTokenHeader
		)

		return try HealthCertificate(base45: base45, validityState: validityState)
	}

}
