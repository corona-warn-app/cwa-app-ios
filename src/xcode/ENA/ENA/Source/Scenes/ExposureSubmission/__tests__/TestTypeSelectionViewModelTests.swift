//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

final class TestTypeSelectionViewModelTests: XCTestCase {

    func test_When_DynamicTableViewModel_Then_NumberOfCellsAndTypeIsCorrect() throws {
		// Given
		let sut = SRSTestTypeSelectionViewModel(isSelfTestTypePreselected: false)
		let cells = sut.dynamicTableViewModel.section(0).cells
		
		// Then
		XCTAssertEqual(cells.count, 2)

		[
			DynamicCell.CellReuseIdentifier.dynamicTypeLabel.rawValue,
			SRSTestTypeSelectionViewController.CustomCellReuseIdentifiers.optionGroupCell.rawValue
		].enumerated().forEach { index, identifier in
			XCTAssertEqual(cells[index].cellReuseIdentifier.rawValue, identifier)
		}
    }
	
	func test_When_IsSelfTestTypePreselected_False_Then_selectedSubmissionTypeShouldBeNil() throws {
		// Given
		let sut = SRSTestTypeSelectionViewModel(isSelfTestTypePreselected: false)
		
		// Then
		XCTAssertNil(sut.selectedSubmissionType)
	}
	
	func test_When_IsSelfTestTypePreselected_True_Then_selectedSubmissionTypeShouldBeSRSSelfTest() throws {
		DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.1) {
			// Given
			let sut = SRSTestTypeSelectionViewModel(isSelfTestTypePreselected: true)
	
			// Then
			XCTAssertEqual(sut.selectedSubmissionType, .srsSelfTest)
		}
	}
}
