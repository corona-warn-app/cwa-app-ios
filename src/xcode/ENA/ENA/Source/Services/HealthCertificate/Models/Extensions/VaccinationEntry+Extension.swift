////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

extension VaccinationEntry {

	var isLastDoseInASeries: Bool {
		doseNumber == totalSeriesOfDoses
	}

	var localVaccinationDate: Date? {
		return ISO8601DateFormatter.justLocalDateFormatter.date(from: dateOfVaccination)
	}

	// swiftlint:disable:next cyclomatic_complexity
	func title(for keyPath: PartialKeyPath<VaccinationEntry>) -> String? {
		switch keyPath {
		case \VaccinationEntry.diseaseOrAgentTargeted:
			return "Zielkrankheit oder -erreger / Disease or Agent Targeted"
		case \VaccinationEntry.vaccineOrProphylaxis:
			return "Impfstoff / Vaccine"
		case \VaccinationEntry.vaccineMedicinalProduct:
			return "Art des Impfstoffs / Vaccine Type"
		case \VaccinationEntry.marketingAuthorizationHolder:
			return "Hersteller / Manufacturer"
		case \VaccinationEntry.doseNumber:
			return "Nummer der Impfung / Number in a series of vaccinations"
		case \VaccinationEntry.totalSeriesOfDoses:
			return "Gesamtzahl an Impfdosen / Total number of vaccination doses"
		case \VaccinationEntry.dateOfVaccination:
			return "Datum der Impfung / Date of Vaccination (YYYY-MM-DD)"
		case \VaccinationEntry.countryOfVaccination:
			return "Land der Impfung / Member State of Vaccination"
		case \VaccinationEntry.certificateIssuer:
			return "Zertifikataussteller / Certificate Issuer"
		case \VaccinationEntry.uniqueCertificateIdentifier:
			return "Zertifikatkennung / Unique Certificate Identifier"
		default:
			return nil
		}
	}

	// swiftlint:disable:next cyclomatic_complexity
	func formattedValue(for keyPath: PartialKeyPath<VaccinationEntry>, valueSets: SAP_Internal_Dgc_ValueSets?) -> String? {
		switch keyPath {
		case \VaccinationEntry.diseaseOrAgentTargeted:
			return valueSets?
				.valueSet(for: .diseaseOrAgentTargeted)?
				.displayText(forKey: diseaseOrAgentTargeted)
		case \VaccinationEntry.vaccineOrProphylaxis:
			return valueSets?
				.valueSet(for: .vaccineOrProphylaxis)?
				.displayText(forKey: vaccineOrProphylaxis)
		case \VaccinationEntry.vaccineMedicinalProduct:
			return valueSets?
				.valueSet(for: .vaccineMedicinalProduct)?
				.displayText(forKey: vaccineMedicinalProduct)
		case \VaccinationEntry.marketingAuthorizationHolder:
			return valueSets?
				.valueSet(for: .marketingAuthorizationHolder)?
				.displayText(forKey: marketingAuthorizationHolder)
		case \VaccinationEntry.doseNumber:
			return String(doseNumber)
		case \VaccinationEntry.totalSeriesOfDoses:
			return String(totalSeriesOfDoses)
		case \VaccinationEntry.dateOfVaccination:
			return DCCDateStringFormatter.formattedString(from: dateOfVaccination)
		case \VaccinationEntry.countryOfVaccination:
			return Country(countryCode: countryOfVaccination)?.localizedName ?? countryOfVaccination
		case \VaccinationEntry.certificateIssuer:
			return certificateIssuer
		case \VaccinationEntry.uniqueCertificateIdentifier:
			return uniqueCertificateIdentifier
		default:
			return nil
		}
	}

}
