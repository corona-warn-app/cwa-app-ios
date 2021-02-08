////
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest

class UserMetadataTests: XCTestCase {

	func testUserMetadata() throws {
		let store = MockTestStore()
		store.userMetadata = UserMetadata(
			federalState: "Baden-Württemberg",
			administrativeUnit: "Walldorf",
			ageGroup: .ageBelow29
		)
		XCTAssertEqual(store.userMetadata?.federalState, "Baden-Württemberg")
		XCTAssertEqual(store.userMetadata?.administrativeUnit, "Walldorf")
		XCTAssertEqual(store.userMetadata?.ageGroup, .ageBelow29)
	}

}
