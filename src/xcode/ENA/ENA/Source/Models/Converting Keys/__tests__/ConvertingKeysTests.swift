//
// 🦠 Corona-Warn-App
//

import XCTest
import ExposureNotification
@testable import ENA

final class ConvertingKeysTests: XCTestCase {
	func testToSapKeyConversion() {
		let key = TemporaryExposureKeyMock(
			keyData: Data("hello".utf8),
			rollingPeriod: 123,
			rollingStartNumber: 456,
			transmissionRiskLevel: 88
		).sapKey
		XCTAssertEqual(key.keyData, Data("hello".utf8))
		XCTAssertEqual(key.rollingPeriod, 123)
		XCTAssertEqual(key.rollingStartIntervalNumber, 456)
		XCTAssertEqual(key.transmissionRiskLevel, 88)
	}
}
