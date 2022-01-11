//
// 🦠 Corona-Warn-App
//

import Foundation

import HealthCertificateToolkit
import class CertLogic.Rule

struct ValidationRules: CBORDecoding {

	init(decodeCBOR: Data) throws {
		switch ValidationRulesAccess().extractValidationRules(from: decodeCBOR) {
		case .success(let rules):
			self.rules = rules
		case .failure(let error):
			throw error
		}
	}

	// MARK: - Internal

	let rules: [Rule]

}
