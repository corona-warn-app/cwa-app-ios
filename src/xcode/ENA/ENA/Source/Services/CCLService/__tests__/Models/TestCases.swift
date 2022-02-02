//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

struct DCCUITextTestCases: Decodable {
	
	// MARK: - Internal

	let testCases: [DCCUITextTestCase]
}

struct DCCUITextAssertion: Decodable {
	
	// MARK: - Internal

	let languageCode: String
	let text: String
}


struct DCCUITextTestCase: Decodable {

	// MARK: - Internal

	let description: String
	let textDescriptor: DCCUIText
	let assertions: [DCCUITextAssertion]
	
}
