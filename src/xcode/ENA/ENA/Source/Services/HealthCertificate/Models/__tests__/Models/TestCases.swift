//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

struct TestCasesWithCCLConfiguration: Decodable {
	
	// MARK: - Internal

	let testCases: [CCLTestCase]
}

struct Assertion: Decodable {
	
	// MARK: - Internal

	let languageCode: String
	let text: String
}


struct CCLTestCase: Decodable {

	// MARK: - Internal

	let description: String
	let textDescriptor: DCCUIText
	let assertions: [Assertion]
	
}
