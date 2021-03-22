////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class TraceLocationTypeTest: XCTestCase {

	func testGIVEN_locationTypeUnspecified_THEN_TitleAndSubtitleMatch() {
		// GIVEN
		let traceLocationType: TraceLocationType = .locationTypeUnspecified

		// THEN
		XCTAssertEqual(AppStrings.TraceLocations.unspecified.title, traceLocationType.title)
	}

	func testGIVEN_locationTypePermanentOther_THEN_TitleAndSubtitleMatch() {
		// GIVEN
		let traceLocationType: TraceLocationType = .locationTypePermanentOther

		// THEN
		XCTAssertEqual(AppStrings.TraceLocations.permanent.title.other, traceLocationType.title)
	}

	func testGIVEN_locationTypeTemporaryOther_THEN_TitleAndSubtitleMatch() {
		// GIVEN
		let traceLocationType: TraceLocationType = .locationTypeTemporaryOther

		// THEN
		XCTAssertEqual(AppStrings.TraceLocations.temporary.title.other, traceLocationType.title)
	}

	func testGIVEN_locationTypePermanentRetail_THEN_TitleAndSubtitleMatch() {
		// GIVEN
		let traceLocationType: TraceLocationType = .locationTypePermanentRetail

		// THEN
		XCTAssertEqual(AppStrings.TraceLocations.permanent.title.retail, traceLocationType.title)
	}

	func testGIVEN_locationTypePermanentFoodService_THEN_TitleAndSubtitleMatch() {
		// GIVEN
		let traceLocationType: TraceLocationType = .locationTypePermanentFoodService

		// THEN
		XCTAssertEqual(AppStrings.TraceLocations.permanent.title.foodService, traceLocationType.title)
	}

	func testGIVEN_locationTypePermanentCraft_THEN_TitleAndSubtitleMatch() {
		// GIVEN
		let traceLocationType: TraceLocationType = .locationTypePermanentCraft

		// THEN
		XCTAssertEqual(AppStrings.TraceLocations.permanent.title.craft, traceLocationType.title)
	}

	func testGIVEN_locationTypePermanentWorkplace_THEN_TitleAndSubtitleMatch() {
		// GIVEN
		let traceLocationType: TraceLocationType = .locationTypePermanentWorkplace

		// THEN
		XCTAssertEqual(AppStrings.TraceLocations.permanent.title.workplace, traceLocationType.title)
	}

	func testGIVEN_locationTypePermanentEducationalInstitution_THEN_TitleAndSubtitleMatch() {
		// GIVEN
		let traceLocationType: TraceLocationType = .locationTypePermanentEducationalInstitution

		// THEN
		XCTAssertEqual(AppStrings.TraceLocations.permanent.title.educationalInstitution, traceLocationType.title)
	}

	func testGIVEN_locationTypePermanentPublicBuilding_THEN_TitleAndSubtitleMatch() {
		// GIVEN
		let traceLocationType: TraceLocationType = .locationTypePermanentPublicBuilding

		// THEN
		XCTAssertEqual(AppStrings.TraceLocations.permanent.title.publicBuilding, traceLocationType.title)
	}

	func testGIVEN_locationTypeTemporaryCulturalEvent_THEN_TitleAndSubtitleMatch() {
		// GIVEN
		let traceLocationType: TraceLocationType = .locationTypeTemporaryCulturalEvent

		// THEN
		XCTAssertEqual(AppStrings.TraceLocations.temporary.title.culturalEvent, traceLocationType.title)
	}

	func testGIVEN_locationTypeTemporaryClubActivity_THEN_TitleAndSubtitleMatch() {
		// GIVEN
		let traceLocationType: TraceLocationType = .locationTypeTemporaryClubActivity

		// THEN
		XCTAssertEqual(AppStrings.TraceLocations.temporary.title.clubActivity, traceLocationType.title)
	}

	func testGIVEN_locationTypeTemporaryPrivateEvent_THEN_TitleAndSubtitleMatch() {
		// GIVEN
		let traceLocationType: TraceLocationType = .locationTypeTemporaryPrivateEvent

		// THEN
		XCTAssertEqual(AppStrings.TraceLocations.temporary.title.privateEvent, traceLocationType.title)
	}

	func testGIVEN_locationTypeTemporaryWorshipService_THEN_TitleAndSubtitleMatch() {
		// GIVEN
		let traceLocationType: TraceLocationType = .locationTypeTemporaryWorshipService

		// THEN
		XCTAssertEqual(AppStrings.TraceLocations.temporary.title.worshipService, traceLocationType.title)
	}

}
