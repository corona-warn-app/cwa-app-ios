////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class LocaleSupportedLanguageTests: XCTestCase {

    func testOnlySupportedLanguagesAreReturned() throws {
		XCTAssertEqual(Locale(identifier: "de").languageCodeIfSupported, "de")
		XCTAssertEqual(Locale(identifier: "de_LI").languageCodeIfSupported, "de")
		XCTAssertEqual(Locale(identifier: "de_CH").languageCodeIfSupported, "de")
		XCTAssertEqual(Locale(identifier: "en").languageCodeIfSupported, "en")
		XCTAssertEqual(Locale(identifier: "bg").languageCodeIfSupported, "bg")
		XCTAssertEqual(Locale(identifier: "tr").languageCodeIfSupported, "tr")
		XCTAssertEqual(Locale(identifier: "pl").languageCodeIfSupported, "pl")
		XCTAssertEqual(Locale(identifier: "ro").languageCodeIfSupported, "ro")

		XCTAssertNil(Locale(identifier: "fr").languageCodeIfSupported)
		XCTAssertNil(Locale(identifier: "es").languageCodeIfSupported)
		XCTAssertNil(Locale(identifier: "ru").languageCodeIfSupported)
		XCTAssertNil(Locale(identifier: "sv_SE").languageCodeIfSupported)
		XCTAssertNil(Locale(identifier: "hu_HU").languageCodeIfSupported)
		XCTAssertNil(Locale(identifier: "pt").languageCodeIfSupported)
		XCTAssertNil(Locale(identifier: "eo").languageCodeIfSupported)
		XCTAssertNil(Locale(identifier: "it").languageCodeIfSupported)
		XCTAssertNil(Locale(identifier: "da").languageCodeIfSupported)
    }

}
