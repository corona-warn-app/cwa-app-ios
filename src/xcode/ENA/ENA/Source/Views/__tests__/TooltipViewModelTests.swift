//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class TooltipViewModelTests: XCTestCase {

	func testGIVEN_ExportCertificates_WHEN_Title_THEN_StringAsExpected() {
		// GIVEN
		let sut = TooltipViewModel(for: .exportCertificates)
		
		// WHEN
		let title = sut.title
		
		// THEN
		XCTAssertEqual(title, AppStrings.Tooltip.ExportCertificates.title)
	}
	
	func testGIVEN_ExportCertificates_WHEN_Description_THEN_StringAsExpected() {
		// GIVEN
		let sut = TooltipViewModel(for: .exportCertificates)
		
		// WHEN
		let title = sut.description
		
		// THEN
		XCTAssertEqual(title, AppStrings.Tooltip.ExportCertificates.description)
	}
	
	func testGIVEN_Custom_WHEN_Title_THEN_StringAsExpected() {
		// GIVEN
		let sut = TooltipViewModel(for: .custom(title: "Test Title", description: ""))
		
		// WHEN
		let title = sut.title
		
		// THEN
		XCTAssertEqual(title, "Test Title")
	}
	
	func testGIVEN_Custom_WHEN_Description_THEN_StringAsExpected() {
		// GIVEN
		let sut = TooltipViewModel(for: .custom(title: "", description: "Test Desc"))
		
		// WHEN
		let title = sut.description
		
		// THEN
		XCTAssertEqual(title, "Test Desc")
	}
}
