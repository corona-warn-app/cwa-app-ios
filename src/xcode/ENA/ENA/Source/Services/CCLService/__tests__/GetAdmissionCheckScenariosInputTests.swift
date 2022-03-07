//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
import AnyCodable
@testable import ENA

class GetAdmissionCheckScenariosInputTests: XCTestCase {

	func test_InputData() throws {
		let input = GetAdmissionCheckScenariosInput.make(with: Date(), language: "de")

		XCTAssertEqual(input["os"], AnyDecodable("ios"))
		XCTAssertEqual(input["language"], AnyDecodable("de"))
		XCTAssertNotNil(input["now"])
	}

}
