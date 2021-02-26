////
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest

class UserdataTests: XCTestCase {

	func testUserMetadata_ageBelow29() throws {
		let store = MockTestStore()
		store.userData = UserMetadata(
			federalState: .badenWürttemberg,
			// Rhein-Neckar-Kreis
			administrativeUnit: 11008226,
			ageGroup: .ageBelow29
		)
		XCTAssertEqual(store.userData?.federalState, .badenWürttemberg)
		XCTAssertEqual(store.userData?.administrativeUnit, 11008226)
		XCTAssertEqual(store.userData?.ageGroup, .ageBelow29)
	}
	
	func testUserMetadata_ageBetween30And59() throws {
		let store = MockTestStore()
		store.userData = UserMetadata(
			federalState: .badenWürttemberg,
			// Heidelberg
			administrativeUnit: 11008221,
			ageGroup: .ageBetween30And59
		)
		XCTAssertEqual(store.userData?.federalState, .badenWürttemberg)
		XCTAssertEqual(store.userData?.administrativeUnit, 11008221)
		XCTAssertEqual(store.userData?.ageGroup, .ageBetween30And59)
	}
	
	func testUserMetadata_age60OrAbove() throws {
		let store = MockTestStore()
		store.userData = UserMetadata(
			federalState: .badenWürttemberg,
			// Mannheim
			administrativeUnit: 11008222,
			ageGroup: .age60OrAbove
		)
		XCTAssertEqual(store.userData?.federalState, .badenWürttemberg)
		XCTAssertEqual(store.userData?.administrativeUnit, 11008222)
		XCTAssertEqual(store.userData?.ageGroup, .age60OrAbove)
	}

}
