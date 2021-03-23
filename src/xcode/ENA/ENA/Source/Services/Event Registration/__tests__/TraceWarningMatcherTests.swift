////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class TraceWarningMatcherTests: XCTestCase {

	func test_When_PackageContainsWarningWithMatch_Then_MatchIsPersisted() {
		let store = MockEventStore()
		let matcher = TraceWarningMatcher()

		let warningPackage = SAP_Internal_Pt_TraceWarningPackage()

	}

}
