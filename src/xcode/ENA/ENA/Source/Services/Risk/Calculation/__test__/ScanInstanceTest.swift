//
// 🦠 Corona-Warn-App
//


import XCTest
import ExposureNotification
@testable import ENA

class ScanInstanceTest: XCTestCase {

	func testGIVEN_JsonScanInstance_WHEN_Converted_THEN_ValuesMatch() throws {
		// GIVEN
		let jsonData = """
			{
			  "typicalAttenuation": 30,
			  "minAttenuation": 25,
			  "secondsSinceLastScan": 300
			}
		""".data(using: .utf8)

		// WHEN
		let scanInstance = try JSONDecoder().decode(ScanInstance.self, from: XCTUnwrap(jsonData))

		// THEN
		XCTAssertEqual(scanInstance.typicalAttenuation, 30)
		XCTAssertEqual(scanInstance.minAttenuation, 25)
		XCTAssertEqual(scanInstance.secondsSinceLastScan, 300)
	}

}
