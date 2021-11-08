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

	var doseNumberAndTotalSeriesOfDoses: String {
		"\(doseNumber) of \(totalSeriesOfDoses)"
	}

	// if administered with one dost of AstraZeneca, Moderna or BioNTech as recovery vaccination
	var isRecoveredVaccination: Bool {
		switch VaccinationProductType(value: vaccineMedicinalProduct) {
		case .biontech, .astraZeneca, .moderna:
			return totalSeriesOfDoses == 1 && doseNumber == 1
		case .johnsonAndJohnson, .other:
			return false
		}
	}

	// is booster if -> AstraZeneca, Moderna and BioNTech, dose is 3 or more, Johnson & Johnson if dose is 2 or more
	var isBoosterVaccination: Bool {
		switch VaccinationProductType(value: vaccineMedicinalProduct) {
		case .biontech, .astraZeneca, .moderna:
			return doseNumber > 2
		case .johnsonAndJohnson:
			return doseNumber > 1
		case .other:
			return false
		}
	}
	
	// if the booster was administered with AstraZeneca, Moderna or BioNTech
	var isBoosterWithBMA: Bool {
		switch VaccinationProductType(value: vaccineMedicinalProduct) {
		case .biontech, .astraZeneca, .moderna:
			return doseNumber > 2
		case .johnsonAndJohnson:
			return false
		case .other:
			return false
		}
	}
	
	// if the booster was administered with Johnson & Johnson
	var isBoosterWithJohnsonAndJohnson: Bool {
		switch VaccinationProductType(value: vaccineMedicinalProduct) {
		case .biontech, .astraZeneca, .moderna:
			return false
		case .johnsonAndJohnson:
			return doseNumber > 1
		case .other:
			return false
		}
	}
	
	// swiftlint:disable:next cyclomatic_complexity
	func title(for keyPath: PartialKeyPath<VaccinationEntry>) -> String? {
		switch keyPath {
		case \VaccinationEntry.diseaseOrAgentTargeted:
			return "Zielkrankheit oder -erreger / Disease or Agent Targeted"
		case \VaccinationEntry.vaccineOrProphylaxis:
			return "Art des Impfstoffs / Vaccine Type"
		case \VaccinationEntry.vaccineMedicinalProduct:
			return "Impfstoff / Vaccine"
		case \VaccinationEntry.marketingAuthorizationHolder:
			return "Hersteller / Manufacturer"
		case \VaccinationEntry.doseNumber:
			return "Nummer der Impfung / Number in a series of vaccinations"
		case \VaccinationEntry.totalSeriesOfDoses:
			return "Gesamtzahl an Impfdosen / Total number of vaccination doses"
		case \VaccinationEntry.doseNumberAndTotalSeriesOfDoses:
			return "Nummer der Impfung / Number in a series of vaccinations"
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
				.displayText(forKey: diseaseOrAgentTargeted) ?? diseaseOrAgentTargeted
		case \VaccinationEntry.vaccineOrProphylaxis:
			return valueSets?
				.valueSet(for: .vaccineOrProphylaxis)?
				.displayText(forKey: vaccineOrProphylaxis) ?? vaccineOrProphylaxis
		case \VaccinationEntry.vaccineMedicinalProduct:
			return valueSets?
				.valueSet(for: .vaccineMedicinalProduct)?
				.displayText(forKey: vaccineMedicinalProduct) ?? vaccineMedicinalProduct
		case \VaccinationEntry.marketingAuthorizationHolder:
			return valueSets?
				.valueSet(for: .marketingAuthorizationHolder)?
				.displayText(forKey: marketingAuthorizationHolder) ?? marketingAuthorizationHolder
		case \VaccinationEntry.doseNumber:
			return String(doseNumber)
		case \VaccinationEntry.totalSeriesOfDoses:
			return String(totalSeriesOfDoses)
		case \VaccinationEntry.doseNumberAndTotalSeriesOfDoses:
			return doseNumberAndTotalSeriesOfDoses
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
