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
		case booster
		case seriesCompleting
		case recovery
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
			from: DigitalCovidCertificate.fake(
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
			from: DigitalCovidCertificate.fake(
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
		validityState: HealthCertificateValidityState = .valid
	) throws -> HealthCertificate {
		var vaccinations = [(vaccinationProductType: VaccinationProductType, doseNumber: Int, totalSeriesOfDoses: Int)]()

		switch type {
		case .booster:
			let doseNumberGreater1 = Int.random(in: 2...9)
			let doseNumberGreater2 = Int.random(in: 3...9)
			vaccinations = [
				(vaccinationProductType: .astraZeneca, doseNumber: doseNumberGreater2, totalSeriesOfDoses: doseNumberGreater2),
				(vaccinationProductType: .biontech, doseNumber: doseNumberGreater2, totalSeriesOfDoses: doseNumberGreater2),
				(vaccinationProductType: .moderna, doseNumber: doseNumberGreater2, totalSeriesOfDoses: doseNumberGreater2),
				(vaccinationProductType: .johnsonAndJohnson, doseNumber: doseNumberGreater1, totalSeriesOfDoses: doseNumberGreater1)
			]
		case .seriesCompleting:
			vaccinations = [
				(vaccinationProductType: .astraZeneca, doseNumber: 2, totalSeriesOfDoses: 2),
				(vaccinationProductType: .biontech, doseNumber: 2, totalSeriesOfDoses: 2),
				(vaccinationProductType: .moderna, doseNumber: 2, totalSeriesOfDoses: 2),
				(vaccinationProductType: .johnsonAndJohnson, doseNumber: 1, totalSeriesOfDoses: 1)
			]
		case .recovery:
			vaccinations = [
				(vaccinationProductType: .astraZeneca, doseNumber: 1, totalSeriesOfDoses: 1),
				(vaccinationProductType: .biontech, doseNumber: 1, totalSeriesOfDoses: 1),
				(vaccinationProductType: .moderna, doseNumber: 1, totalSeriesOfDoses: 1)
			]
		case .incomplete:
			vaccinations = [
				(vaccinationProductType: .astraZeneca, doseNumber: 1, totalSeriesOfDoses: 2),
				(vaccinationProductType: .biontech, doseNumber: 1, totalSeriesOfDoses: 2),
				(vaccinationProductType: .moderna, doseNumber: 1, totalSeriesOfDoses: 2)
			]
		}

		let vaccination = try XCTUnwrap(vaccinations.randomElement())

		guard let vaccinationDate = Calendar.current.date(byAdding: .day, value: -ageInDays, to: Date()) else {
			throw MockError.error("Could not create date")
		}
		let formattedVaccinationDate = ISO8601DateFormatter.string(from: vaccinationDate, timeZone: .current, formatOptions: .withFullDate)

		let base45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				vaccinationEntries: [
					VaccinationEntry.fake(
						vaccineMedicinalProduct: vaccination.vaccinationProductType.value ?? "",
						doseNumber: vaccination.doseNumber,
						totalSeriesOfDoses: vaccination.totalSeriesOfDoses,
						dateOfVaccination: formattedVaccinationDate
					)
				]
			)
		)

		return try HealthCertificate(base45: base45, validityState: validityState)
	}

}
