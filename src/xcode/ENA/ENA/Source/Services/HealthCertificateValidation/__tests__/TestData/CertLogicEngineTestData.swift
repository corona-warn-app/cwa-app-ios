////
// 🦠 Corona-Warn-App
//

import Foundation
import CertLogic

struct CertLogicEngineTestData: Codable {
	let general: CertLogicEngineGeneral
	let testCases: [CertLogicEngineTestCase]
}

struct CertLogicEngineGeneral: Codable {
	let valueSetProtocolBuffer: String
}

struct CertLogicEngineTestCase: Codable {

	let testCaseDescription, dcc: String
	let rules: [Rule]
	let countryOfArrival: String
	let validationClock, expPass, expFail, expOpen: Int

	enum CodingKeys: String, CodingKey {
		case testCaseDescription = "description"
		case dcc, rules, countryOfArrival, validationClock, expPass, expFail, expOpen
	}
}
