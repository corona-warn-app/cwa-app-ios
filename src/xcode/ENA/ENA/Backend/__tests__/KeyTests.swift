//
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest

class KeyTests: XCTestCase {
	// This is a very basic sanity test just to make sure that encoding and decoding of keys
	// works. Currently this is needed by the developer menu in order to transfer keys from
	// device to device.
	func testKeyEncodeDecode() throws {
		var kIn = SAP_External_Exposurenotification_TemporaryExposureKey()
		kIn.keyData = Data(bytes: [1, 2, 3], count: 3)
		kIn.rollingPeriod = 1337
		kIn.rollingStartIntervalNumber = 42
		kIn.transmissionRiskLevel = 8

		let dataIn = try kIn.serializedData()
		let kOut = try SAP_External_Exposurenotification_TemporaryExposureKey(serializedData: dataIn)
		XCTAssertEqual(kOut.keyData, Data(bytes: [1, 2, 3], count: 3))
		XCTAssertEqual(kOut.rollingPeriod, 1337)
		XCTAssertEqual(kOut.rollingStartIntervalNumber, 42)
		XCTAssertEqual(kOut.transmissionRiskLevel, 8)
	}
}
