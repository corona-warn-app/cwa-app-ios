////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class HomeShownPositiveTestResultCellModelTest: XCTestCase {

    func testShownPositivePCRTest() throws {
		let coronaTestService = CoronaTestService(
			client: ClientMock(),
			store: MockTestStore(),
			appConfiguration: CachedAppConfigurationMock()
		)

		coronaTestService.pcrTest = PCRTest.mock(
			registrationDate: Date(timeIntervalSinceReferenceDate: 0),
			testResult: .positive,
			positiveTestResultWasShown: true,
			keysSubmitted: false
		)

		let sut = HomeShownPositiveTestResultCellModel(
			coronaTestType: .pcr,
			coronaTestService: coronaTestService,
			onUpdate: {}
		)
		let expectedInsets = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0)
		
		XCTAssertEqual(sut.title, AppStrings.Home.TestResult.pcrTitle)
		XCTAssertEqual(sut.statusTitle, AppStrings.Home.TestResult.ShownPositive.statusTitle)
		XCTAssertEqual(sut.statusSubtitle, AppStrings.Home.TestResult.ShownPositive.statusSubtitle)
		XCTAssertNotNil(sut.statusFootnote)
		XCTAssertEqual(sut.noteTitle, AppStrings.Home.TestResult.ShownPositive.noteTitle)
		XCTAssertEqual(sut.buttonTitle, AppStrings.Home.TestResult.ShownPositive.button)
		XCTAssertEqual(sut.iconColor, .enaColor(for: .riskHigh))
		
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
