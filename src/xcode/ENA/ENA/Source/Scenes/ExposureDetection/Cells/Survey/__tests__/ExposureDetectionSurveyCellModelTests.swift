////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ExposureDetectionSurveyCellModelTests: XCTestCase {

	func testGIVEN_ExposureDetectionSurveyCellModel_THEN_InitilizedAsExpected() {
		// GIVEN
		let exposureDetectionSurveyCellModel = ExposureDetectionSurveyCellModel()

		// THEN
		XCTAssertEqual(exposureDetectionSurveyCellModel.title, AppStrings.ExposureDetection.surveyCardTitle)
		XCTAssertEqual(exposureDetectionSurveyCellModel.description, AppStrings.ExposureDetection.surveyCardBody)
		XCTAssertEqual(exposureDetectionSurveyCellModel.buttonTitle, AppStrings.ExposureDetection.surveyCardButton)
		XCTAssertEqual(exposureDetectionSurveyCellModel.image, UIImage(named: "Illu_Survey"))
		XCTAssertEqual(exposureDetectionSurveyCellModel.accessibilityIdentifier, AccessibilityIdentifiers.ExposureDetection.surveyCardCell)
	}
}
