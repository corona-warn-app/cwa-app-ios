////
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest

class UserMetadataTests: XCTestCase {

	func testUserMetadata_ageBelow29() throws {
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
	
	func testUserMetadata_ageBetween30And59() throws {
		let store = MockTestStore()
		store.userMetadata = UserMetadata(
			federalState: "Baden-Württemberg",
			administrativeUnit: "Heidelberg",
			ageGroup: .ageBetween30And59
		)
		XCTAssertEqual(store.userMetadata?.federalState, "Baden-Württemberg")
		XCTAssertEqual(store.userMetadata?.administrativeUnit, "Heidelberg")
		XCTAssertEqual(store.userMetadata?.ageGroup, .ageBetween30And59)
	}
	
	func testUserMetadata_age60OrAbove() throws {
		let store = MockTestStore()
		store.userMetadata = UserMetadata(
			federalState: "Baden-Württemberg",
			administrativeUnit: "Mannheim",
			ageGroup: .age60OrAbove
		)
		XCTAssertEqual(store.userMetadata?.federalState, "Baden-Württemberg")
		XCTAssertEqual(store.userMetadata?.administrativeUnit, "Mannheim")
		XCTAssertEqual(store.userMetadata?.ageGroup, .age60OrAbove)
	}

}
