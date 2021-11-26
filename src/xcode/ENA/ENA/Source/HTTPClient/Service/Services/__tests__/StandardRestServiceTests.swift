//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class StandardRestServiceTests: XCTestCase {
	
	func testGIVEN_StandardRestServiceTests_WHEN_Init_THEN_PinningShouldBeActive() {
		
		// GIVEN & WHEN
		
		let restService = StandardRestService()
		
		// THEN
		// When the session's delegate is not nil, the certificate pinning should be activated.
		XCTAssertNotNil(restService.session.delegate)
	}
}
