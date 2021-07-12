////
// 🦠 Corona-Warn-App
//

import Foundation
import CertLogic

struct CertEngineTestData: Codable {
	let general: CertEngineGeneral
	let testCases: [CertEngineTestCase]
}

struct CertEngineGeneral: Codable {
	let valueSetProtocolBuffer: String
}

struct CertEngineTestCase: Codable {

	let testCaseDescription, dcc: String
	let rules: [Rule]
	let countryOfArrival: String
	let validationClock, expPass, expFail, expOpen: Int

	enum CodingKeys: String, CodingKey {
		case testCaseDescription = "description"
		case dcc, rules, countryOfArrival, validationClock, expPass, expFail, expOpen
	}
}
