//
// 🦠 Corona-Warn-App
//

import XCTest
import ZIPFoundation
@testable import ENA

class AppConfiguration_Features: XCTestCase {

	func testGIVEN_DefaultAppConfiguration_WHEN_getFeatures_THEN_allMatchDefaultValues() throws {
		let url = try XCTUnwrap(Bundle.main.url(forResource: "default_app_config_270", withExtension: ""))
		let data = try Data(contentsOf: url)
		let zip = try XCTUnwrap(Archive(data: data, accessMode: .read))
		let config = try zip.extractAppConfiguration()

		// WHEN
		let disableDeviceTimeCheck = config.value(for: .disableDeviceTimeCheck)
		let unencryptedCheckinsEnabled = config.value(for: .unencryptedCheckinsEnabled)

		// THEN
		XCTAssertFalse(disableDeviceTimeCheck)
		XCTAssertFalse(unencryptedCheckinsEnabled)
	}
}
