////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class HomeShownPositiveTestResultCellModelTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testModel() throws {
        let sut = HomeShownPositiveTestResultCellModel()
		let expectedInsets = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0)
		
		XCTAssertNotNil(sut.backgroundColor)
		XCTAssertNotNil(sut.title)
		XCTAssertNotNil(sut.statusTitle)
		XCTAssertNotNil(sut.statusSubtitle)
		XCTAssertNotNil(sut.statusTitleColor)
		XCTAssertNotNil(sut.statusLineColor)
		XCTAssertNotNil(sut.statusImageName)
		XCTAssertNotNil(sut.noteTitle)
		XCTAssertNotNil(sut.buttonTitle)
		XCTAssertNotNil(sut.iconColor)
		
		let arrayHomeItemViewModel = sut.homeItemViewModels
		XCTAssertEqual(arrayHomeItemViewModel.count, 3)
		
		for i in 0..<arrayHomeItemViewModel.count {
			guard let item = arrayHomeItemViewModel[i] as? HomeImageItemViewModel else {
				return
			}
			XCTAssertNotNil(item.title)
			XCTAssertNotNil(item.titleColor)
			XCTAssertNotNil(item.iconImageName)
			XCTAssertNotNil(item.iconTintColor)
			XCTAssertNotNil(item.color)
			XCTAssertNotNil(item.separatorColor)
			XCTAssertEqual(item.containerInsets, expectedInsets)
		}
    }

}
