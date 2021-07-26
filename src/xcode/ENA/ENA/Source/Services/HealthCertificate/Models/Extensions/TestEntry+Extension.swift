////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

extension TestEntry {

	static let pcrTypeString = "LP6464-4"
	static let antigenTypeString = "LP217198-3"

	var sampleCollectionDate: Date? {
		let iso8601FormatterWithFractionalSeconds = ISO8601DateFormatter()
		iso8601FormatterWithFractionalSeconds.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

		return iso8601FormatterWithFractionalSeconds.date(from: dateTimeOfSampleCollection) ??
			ISO8601DateFormatter().date(from: dateTimeOfSampleCollection)
	}

	var coronaTestType: CoronaTestType? {
		switch typeOfTest {
		case Self.pcrTypeString:
			return .pcr
		case Self.antigenTypeString:
			return .antigen
		default:
			return nil
		}
	}

	// swiftlint:disable:next cyclomatic_complexity
	func title(for keyPath: PartialKeyPath<TestEntry>) -> String? {
		switch keyPath {
		case \TestEntry.diseaseOrAgentTargeted:
			return "Zielkrankheit oder -erreger / Disease or Agent Targeted"
		case \TestEntry.typeOfTest:
			return "Art des Tests / Type of Test"
		case \TestEntry.naaTestName:
			return "Produktname / Test Name"
		case \TestEntry.ratTestName:
			return "Testhersteller / Test Manufacturer"
		case \TestEntry.sampleCollectionDate:
			return "Datum und Uhrzeit der Probenahme / Date and Time of Sample Collection (YYYY-MM-DD hh:mm Z)"
		case \TestEntry.testResult:
			return "Testergebnis / Test Result"
		case \TestEntry.testCenter:
			return "Testzentrum oder -einrichtung / Testing Center or Facility"
		case \TestEntry.countryOfTest:
			return "Land der Testung / Member State of Test"
		case \TestEntry.certificateIssuer:
			return "Zertifikataussteller / Certificate Issuer"
		case \TestEntry.uniqueCertificateIdentifier:
			return "Zertifikatkennung / Unique Certificate Identifier"
		default:
			return nil
		}
	}

	// swiftlint:disable:next cyclomatic_complexity
	func formattedValue(for keyPath: PartialKeyPath<TestEntry>, valueSets: SAP_Internal_Dgc_ValueSets?) -> String? {
		switch keyPath {
		case \TestEntry.diseaseOrAgentTargeted:
			return valueSets?
				.valueSet(for: .diseaseOrAgentTargeted)?
				.displayText(forKey: diseaseOrAgentTargeted) ?? diseaseOrAgentTargeted
		case \TestEntry.typeOfTest:
			return valueSets?
				.valueSet(for: .typeOfTest)?
				.displayText(forKey: typeOfTest) ?? typeOfTest
		case \TestEntry.naaTestName:
			return naaTestName
		case \TestEntry.ratTestName:
			return ratTestName.flatMap {
				valueSets?
					.valueSet(for: .rapidAntigenTestNameAndManufacturer)?
					.displayText(forKey: $0) ?? $0
			}
		case \TestEntry.sampleCollectionDate:
			let customDateFormatter = DateFormatter()
			customDateFormatter.dateFormat = "yyyy-MM-dd HH:mm 'UTC' x"
			// Dates for certificates are formatted in Gregorian calendar, even if the user setting is different
			customDateFormatter.calendar = .gregorian()
			return sampleCollectionDate.flatMap {
				customDateFormatter.string(from: $0)
			} ?? dateTimeOfSampleCollection
		case \TestEntry.testResult:
			return valueSets?
				.valueSet(for: .testResult)?
				.displayText(forKey: testResult) ?? testResult
		case \TestEntry.testCenter:
			return testCenter
		case \TestEntry.countryOfTest:
			return Country(countryCode: countryOfTest)?.localizedName ?? countryOfTest
		case \TestEntry.certificateIssuer:
			return certificateIssuer
		case \TestEntry.uniqueCertificateIdentifier:
			return uniqueCertificateIdentifier
		default:
			return nil
		}
	}

}
