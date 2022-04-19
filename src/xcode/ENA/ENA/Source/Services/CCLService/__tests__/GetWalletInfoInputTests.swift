//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
import AnyCodable
@testable import ENA

class GetWalletInfoInputTests: XCTestCase {

	func test_InputData() throws {
		let input = GetWalletInfoInput.make(with: Date(), language: "de", certificates: [], boosterNotificationRules: [], invalidationRules: [], identifier: "")
		
		XCTAssertEqual(input["os"], AnyDecodable("ios"))
		XCTAssertEqual(input["language"], AnyDecodable("de"))
		XCTAssertNotNil(input["now"])
		XCTAssertNotNil(input["certificates"])
		XCTAssertNotNil(input["boosterNotificationRules"])
	}
}
