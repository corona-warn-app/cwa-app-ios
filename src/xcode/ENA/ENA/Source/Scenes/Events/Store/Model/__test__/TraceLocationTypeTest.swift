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
		XCTAssertEqual(traceLocationType.title, AppStrings.TraceLocations.unspecified.title)
		XCTAssertNil(traceLocationType.subtitle)
	}

	func testGIVEN_locationTypePermanentOther_THEN_TitleAndSubtitleMatch() {
		// GIVEN
		let traceLocationType: TraceLocationType = .locationTypePermanentOther

		// THEN
		XCTAssertEqual(traceLocationType.title, AppStrings.TraceLocations.permanent.title.other)
		XCTAssertNil(traceLocationType.subtitle)
	}

	func testGIVEN_locationTypeTemporaryOther_THEN_TitleAndSubtitleMatch() {
		// GIVEN
		let traceLocationType: TraceLocationType = .locationTypeTemporaryOther

		// THEN
		XCTAssertEqual(traceLocationType.title, AppStrings.TraceLocations.temporary.title.other)
		XCTAssertNil(traceLocationType.subtitle)
	}

	func testGIVEN_locationTypePermanentRetail_THEN_TitleAndSubtitleMatch() {
		// GIVEN
		let traceLocationType: TraceLocationType = .locationTypePermanentRetail

		// THEN
		XCTAssertEqual(traceLocationType.title, AppStrings.TraceLocations.permanent.title.retail)
		XCTAssertEqual(traceLocationType.subtitle, AppStrings.TraceLocations.permanent.subtitle.retail)
	}

	func testGIVEN_locationTypePermanentFoodService_THEN_TitleAndSubtitleMatch() {
		// GIVEN
		let traceLocationType: TraceLocationType = .locationTypePermanentFoodService

		// THEN
		XCTAssertEqual(traceLocationType.title, AppStrings.TraceLocations.permanent.title.foodService)
		XCTAssertEqual(traceLocationType.subtitle, AppStrings.TraceLocations.permanent.subtitle.foodService)
	}

	func testGIVEN_locationTypePermanentCraft_THEN_TitleAndSubtitleMatch() {
		// GIVEN
		let traceLocationType: TraceLocationType = .locationTypePermanentCraft

		// THEN
		XCTAssertEqual(traceLocationType.title, AppStrings.TraceLocations.permanent.title.craft)
		XCTAssertEqual(traceLocationType.subtitle, AppStrings.TraceLocations.permanent.subtitle.craft)
	}

	func testGIVEN_locationTypePermanentWorkplace_THEN_TitleAndSubtitleMatch() {
		// GIVEN
		let traceLocationType: TraceLocationType = .locationTypePermanentWorkplace

		// THEN
		XCTAssertEqual(traceLocationType.title, AppStrings.TraceLocations.permanent.title.workplace)
		XCTAssertEqual(traceLocationType.subtitle, AppStrings.TraceLocations.permanent.subtitle.workplace)
	}

	func testGIVEN_locationTypePermanentEducationalInstitution_THEN_TitleAndSubtitleMatch() {
		// GIVEN
		let traceLocationType: TraceLocationType = .locationTypePermanentEducationalInstitution

		// THEN
		XCTAssertEqual(traceLocationType.title, AppStrings.TraceLocations.permanent.title.educationalInstitution)
		XCTAssertEqual(traceLocationType.subtitle, AppStrings.TraceLocations.permanent.subtitle.educationalInstitution)
	}

	func testGIVEN_locationTypePermanentPublicBuilding_THEN_TitleAndSubtitleMatch() {
		// GIVEN
		let traceLocationType: TraceLocationType = .locationTypePermanentPublicBuilding

		// THEN
		XCTAssertEqual(traceLocationType.title, AppStrings.TraceLocations.permanent.title.publicBuilding)
		XCTAssertEqual(traceLocationType.subtitle, AppStrings.TraceLocations.permanent.subtitle.publicBuilding)
	}

	func testGIVEN_locationTypeTemporaryCulturalEvent_THEN_TitleAndSubtitleMatch() {
		// GIVEN
		let traceLocationType: TraceLocationType = .locationTypeTemporaryCulturalEvent

		// THEN
		XCTAssertEqual(traceLocationType.title, AppStrings.TraceLocations.temporary.title.culturalEvent)
		XCTAssertEqual(traceLocationType.subtitle, AppStrings.TraceLocations.temporary.subtitle.culturalEvent)
	}

	func testGIVEN_locationTypeTemporaryClubActivity_THEN_TitleAndSubtitleMatch() {
		// GIVEN
		let traceLocationType: TraceLocationType = .locationTypeTemporaryClubActivity

		// THEN
		XCTAssertEqual(traceLocationType.title, AppStrings.TraceLocations.temporary.title.clubActivity)
		XCTAssertEqual(traceLocationType.subtitle, AppStrings.TraceLocations.temporary.subtitle.clubActivity)
	}

	func testGIVEN_locationTypeTemporaryPrivateEvent_THEN_TitleAndSubtitleMatch() {
		// GIVEN
		let traceLocationType: TraceLocationType = .locationTypeTemporaryPrivateEvent

		// THEN
		XCTAssertEqual(traceLocationType.title, AppStrings.TraceLocations.temporary.title.privateEvent)
		XCTAssertEqual(traceLocationType.subtitle, AppStrings.TraceLocations.temporary.subtitle.privateEvent)
	}

	func testGIVEN_locationTypeTemporaryWorshipService_THEN_TitleAndSubtitleMatch() {
		// GIVEN
		let traceLocationType: TraceLocationType = .locationTypeTemporaryWorshipService

		// THEN
		XCTAssertEqual(traceLocationType.title, AppStrings.TraceLocations.temporary.title.worshipService)
		XCTAssertNil(traceLocationType.subtitle)
	}

}
