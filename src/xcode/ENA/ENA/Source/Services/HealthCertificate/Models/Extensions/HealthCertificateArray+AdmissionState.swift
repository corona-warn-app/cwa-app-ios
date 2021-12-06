////
// 🦠 Corona-Warn-App
//

import Foundation

extension Array where Element == HealthCertificate {

	var admissionState: HealthCertifiedPersonAdmissionState {
		let validOrSoonExpiringCertificates = self
			.filter {
				$0.validityState == .valid || $0.validityState == .expiringSoon
			}
			.sorted()

		let lastCompleteVaccinationCertificate = validOrSoonExpiringCertificates.lastCompleteVaccinationCertificate
		let lastValidRecoveryCertificate = validOrSoonExpiringCertificates.lastValidRecoveryCertificate

		let twoGCertificate = lastCompleteVaccinationCertificate ?? lastValidRecoveryCertificate

		let currentPCRTestCertificate = validOrSoonExpiringCertificates.currentPCRTestCertificate
		let currentAntigenTestCertificate = validOrSoonExpiringCertificates.currentAntigenTestCertificate

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
