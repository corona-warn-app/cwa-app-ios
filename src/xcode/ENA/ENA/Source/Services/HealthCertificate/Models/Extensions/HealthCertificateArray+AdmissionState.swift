////
// 🦠 Corona-Warn-App
//

import Foundation

enum AdmissionState {
	case twoGPlusPCR(twoG: HealthCertificate, pcrTest: HealthCertificate)
	case twoGPlusAntigen(twoG: HealthCertificate, antigenTest: HealthCertificate)
	case twoG
	case threeGWithPCR
	case threeGWithAntigen
	case other
}

extension Array where Element == HealthCertificate {

	var admissionState: AdmissionState {
		let validOrExpiringSoonCertificates = self
			.filter {
				$0.validityState == .valid || $0.validityState == .expiringSoon
			}
			.sorted()

		let lastCompleteVaccinationCertificate = validOrExpiringSoonCertificates.lastCompleteVaccinationCertificate
		let lastValidRecoveryCertificate = validOrExpiringSoonCertificates.lastValidRecoveryCertificate

		let twoGCertificate = lastCompleteVaccinationCertificate ?? lastValidRecoveryCertificate

		let currentPCRTestCertificate = validOrExpiringSoonCertificates.currentPCRTestCertificate
		let currentAntigenTestCertificate = validOrExpiringSoonCertificates.currentAntigenTestCertificate

		switch (twoGCertificate, currentPCRTestCertificate, currentAntigenTestCertificate) {
		case let (.some(twoG), .some(pcrTest), _):
			return .twoGPlusPCR(twoG: twoG, pcrTest: pcrTest)
		case let (.some(twoG), .none, .some(antigenTest)):
			return .twoGPlusAntigen(twoG: twoG, antigenTest: antigenTest)
		case (.some, .none, .none):
			return .twoG
		case (.none, .some, _):
			return .threeGWithPCR
		case (.none, .none, .some):
			return .threeGWithAntigen
		default:
			return .other
		}

	}

}
