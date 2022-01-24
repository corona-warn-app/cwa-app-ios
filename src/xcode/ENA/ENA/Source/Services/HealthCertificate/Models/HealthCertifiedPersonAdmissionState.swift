//
// 🦠 Corona-Warn-App
//

import Foundation

enum HealthCertifiedPersonAdmissionState: Equatable {
	case twoGPlusPCR(twoG: HealthCertificate, pcrTest: HealthCertificate)
	case twoGPlusAntigen(twoG: HealthCertificate, antigenTest: HealthCertificate)
	case twoG(twoG: HealthCertificate)
	case threeGWithPCR
	case threeGWithAntigen
	case other
	
	var subtitle: String? {
		switch self {
		case .twoGPlusPCR:
			return AppStrings.HealthCertificate.Person.AdmissionState.subtitle2GPlusPCR
		case .twoGPlusAntigen:
			return AppStrings.HealthCertificate.Person.AdmissionState.subtitle2GPlusAntigen
		case .twoG(twoG: let twoG) where twoG.vaccinationEntry?.isBoosterVaccination == true:
			return AppStrings.HealthCertificate.Person.AdmissionState.subtitle2GPlus
		case .twoG:
			return AppStrings.HealthCertificate.Person.AdmissionState.subtitle2G
		case .threeGWithPCR:
			return AppStrings.HealthCertificate.Person.AdmissionState.subtitle3GPlus
		case .threeGWithAntigen:
			return AppStrings.HealthCertificate.Person.AdmissionState.subtitle3G
		case .other:
			return nil
		}
	}
	var description: String? {
		switch self {
		case .twoGPlusPCR:
			return AppStrings.HealthCertificate.Person.AdmissionState.description2GPlusPCR
		case .twoGPlusAntigen:
			return AppStrings.HealthCertificate.Person.AdmissionState.description2GPlusAntigen
		case .twoG(twoG: let twoG) where twoG.vaccinationEntry?.isBoosterVaccination == true:
			return AppStrings.HealthCertificate.Person.AdmissionState.description2GPlus
		case .twoG:
			return AppStrings.HealthCertificate.Person.AdmissionState.description2G
		case .threeGWithPCR:
			return AppStrings.HealthCertificate.Person.AdmissionState.description3GPlus
		case .threeGWithAntigen:
			return AppStrings.HealthCertificate.Person.AdmissionState.description3G
		case .other:
			return nil
		}
	}
	
	var shortTitle: String? {
		switch self {
		case .twoGPlusPCR, .twoGPlusAntigen:
			return AppStrings.HealthCertificate.Person.AdmissionState.ShortTitle.title2GPlus
		case .twoG(twoG: let twoG) where twoG.vaccinationEntry?.isBoosterVaccination == true:
			return AppStrings.HealthCertificate.Person.AdmissionState.ShortTitle.title2GPlus
		case .twoG:
			return AppStrings.HealthCertificate.Person.AdmissionState.ShortTitle.title2G
		case .threeGWithPCR:
			return AppStrings.HealthCertificate.Person.AdmissionState.ShortTitle.title3GPlus
		case .threeGWithAntigen:
			return AppStrings.HealthCertificate.Person.AdmissionState.ShortTitle.title3G
		case .other:
			return nil
		}
	}
}
