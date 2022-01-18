//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit
import ENA

struct ValueSetsStub: VaccinationValueSetsProviding {

	var valueSets: SAP_Internal_Dgc_ValueSets

	func latestVaccinationCertificateValueSets() -> AnyPublisher<SAP_Internal_Dgc_ValueSets, Error> {
		// return stubbed value sets; no error
		return Just(valueSets)
			.setFailureType(to: Error.self)
			.eraseToAnyPublisher()
	}

	func fetchVaccinationCertificateValueSets() -> AnyPublisher<SAP_Internal_Dgc_ValueSets, Error> {
		// return stubbed value sets; no error
		return Just(valueSets)
			.setFailureType(to: Error.self)
			.eraseToAnyPublisher()
	}
}
