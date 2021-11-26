//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DisabledPinningRestServiceTests: XCTestCase {
	
	func testGIVEN_DisabledPinningRestService_WHEN_Init_THEN_PinningShouldBeDisabled() {
		
		// GIVEN & WHEN
		
		let restService = DisabledPinningRestService()
		
		// THEN
		// When the session's delegate is nil, the certificate pinning should be disabled.
		XCTAssertNil(restService.session.delegate)
	}
}
