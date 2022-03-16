//
// 🦠 Corona-Warn-App
//

import XCTest
import ZIPFoundation
@testable import ENA

class AppConfiguration_FeaturesTests: XCTestCase {

	// no longer needed?

	func testGIVEN_DefaultAppConfiguration_WHEN_getFeatures_THEN_allMatchDefaultValues() throws {
		let url = try XCTUnwrap(Bundle.main.url(forResource: "default_app_config_2200", withExtension: ""))
		let data = try Data(contentsOf: url)
		let zip = try XCTUnwrap(Archive(data: data, accessMode: .read))
		let config = try zip.extractAppConfiguration()
		let featureProvider = AppFeatureProvider(appConfigurationProvider: CachedAppConfigurationMock(with: config))

		// WHEN
		let disableDeviceTimeCheck = featureProvider.boolValue(for: .disableDeviceTimeCheck)
		let unencryptedCheckinsEnabled = featureProvider.boolValue(for: .unencryptedCheckinsEnabled)

		// THEN
		XCTAssertFalse(disableDeviceTimeCheck)
		XCTAssertFalse(unencryptedCheckinsEnabled)
	}
}
