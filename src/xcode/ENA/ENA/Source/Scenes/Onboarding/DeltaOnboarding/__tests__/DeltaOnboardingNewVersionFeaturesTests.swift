////
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class DeltaOnboardingNewVersionFeaturesTests: XCTestCase {
	
	private var store: Store!
	
	override func setUpWithError() throws {
		store = MockTestStore()
	}

	func testStoreValuesForVersionStoredCorrectly() {
		var currentShownVersion = store.newVersionFeaturesShownForVersion
		
		XCTAssertEqual(currentShownVersion, "1.12", "If no version was set, the default value expected to be '1.12'")
		
		store.newVersionFeaturesShownForVersion = "1.11"
		currentShownVersion = store.newVersionFeaturesShownForVersion
		
		XCTAssertEqual(currentShownVersion, "1.11", "The new version expected to be '1.11'")
	}
}
