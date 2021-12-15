////
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

class HomeShownPositiveTestResultCellModelTest: CWATestCase {

    func testShownPositivePCRTest() throws {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		let coronaTestService = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		coronaTestService.pcrTest = PCRTest.mock(
			registrationDate: Date(timeIntervalSinceReferenceDate: 0),
			testResult: .positive,
			positiveTestResultWasShown: true,
			keysSubmitted: false
		)

		let cellModel = HomeShownPositiveTestResultCellModel(
			coronaTestType: .pcr,
			coronaTestService: coronaTestService,
			onUpdate: {}
		)

		XCTAssertEqual(cellModel.title, AppStrings.Home.TestResult.pcrTitle)
		XCTAssertEqual(cellModel.statusTitle, AppStrings.Home.TestResult.ShownPositive.statusTitle)
		XCTAssertEqual(cellModel.statusSubtitle, AppStrings.Home.TestResult.ShownPositive.statusSubtitle)
		XCTAssertNotNil(cellModel.statusFootnote)
		XCTAssertEqual(cellModel.noteTitle, AppStrings.Home.TestResult.ShownPositive.noteTitle)
		XCTAssertEqual(cellModel.buttonTitle, AppStrings.Home.TestResult.ShownPositive.button)
		XCTAssertFalse(cellModel.isWarnOthersButtonHidden)
		XCTAssertFalse(cellModel.isRemoveTestButtonHidden)

		let homeItemViewModels = cellModel.homeItemViewModels
		XCTAssertEqual(homeItemViewModels.count, 3)
		
		XCTAssertEqual(homeItemViewModels[0].title, AppStrings.Home.TestResult.ShownPositive.phoneItemTitle)
		XCTAssertEqual(homeItemViewModels[0].titleColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(homeItemViewModels[0].iconImageName, "Icons - Hotline")
		XCTAssertEqual(homeItemViewModels[0].iconTintColor, .enaColor(for: .riskHigh))
		XCTAssertEqual(homeItemViewModels[0].color, .clear)
		XCTAssertEqual(homeItemViewModels[0].separatorColor, .clear)
		XCTAssertEqual(homeItemViewModels[0].containerInsets, .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0))

		XCTAssertEqual(homeItemViewModels[1].title, AppStrings.Home.TestResult.ShownPositive.homeItemTitle)
		XCTAssertEqual(homeItemViewModels[1].titleColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(homeItemViewModels[1].iconImageName, "Icons - Home")
		XCTAssertEqual(homeItemViewModels[1].iconTintColor, .enaColor(for: .riskHigh))
		XCTAssertEqual(homeItemViewModels[1].color, .clear)
		XCTAssertEqual(homeItemViewModels[1].separatorColor, .clear)
		XCTAssertEqual(homeItemViewModels[1].containerInsets, .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0))

		XCTAssertEqual(homeItemViewModels[2].title, AppStrings.Home.TestResult.ShownPositive.shareItemTitle)
		XCTAssertEqual(homeItemViewModels[2].titleColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(homeItemViewModels[2].iconImageName, "Icons - Warnen")
		XCTAssertEqual(homeItemViewModels[2].iconTintColor, .enaColor(for: .riskHigh))
		XCTAssertEqual(homeItemViewModels[2].color, .clear)
		XCTAssertEqual(homeItemViewModels[2].separatorColor, .clear)
		XCTAssertEqual(homeItemViewModels[2].containerInsets, .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0))

		coronaTestService.pcrTest?.keysSubmitted = true

		XCTAssertTrue(cellModel.isWarnOthersButtonHidden)
		XCTAssertTrue(cellModel.isRemoveTestButtonHidden)

		let newHomeItemViewModels = cellModel.homeItemViewModels
		XCTAssertEqual(newHomeItemViewModels.count, 2)

		XCTAssertEqual(newHomeItemViewModels[0].title, AppStrings.Home.TestResult.ShownPositive.phoneItemTitle)
		XCTAssertEqual(newHomeItemViewModels[0].titleColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(newHomeItemViewModels[0].iconImageName, "Icons - Hotline")
		XCTAssertEqual(newHomeItemViewModels[0].iconTintColor, .enaColor(for: .riskHigh))
		XCTAssertEqual(newHomeItemViewModels[0].color, .clear)
		XCTAssertEqual(newHomeItemViewModels[0].separatorColor, .clear)
		XCTAssertEqual(newHomeItemViewModels[0].containerInsets, .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0))

		XCTAssertEqual(newHomeItemViewModels[1].title, AppStrings.Home.TestResult.ShownPositive.homeItemTitle)
		XCTAssertEqual(newHomeItemViewModels[1].titleColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(newHomeItemViewModels[1].iconImageName, "Icons - Home")
		XCTAssertEqual(newHomeItemViewModels[1].iconTintColor, .enaColor(for: .riskHigh))
		XCTAssertEqual(newHomeItemViewModels[1].color, .clear)
		XCTAssertEqual(newHomeItemViewModels[1].separatorColor, .clear)
		XCTAssertEqual(newHomeItemViewModels[1].containerInsets, .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0))
    }

	func testShownPositiveAntigenTest() throws {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let coronaTestService = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		coronaTestService.antigenTest = AntigenTest.mock(
			pointOfCareConsentDate: Date(timeIntervalSinceReferenceDate: 0),
			testResult: .positive,
			positiveTestResultWasShown: true,
			keysSubmitted: false
		)

		let cellModel = HomeShownPositiveTestResultCellModel(
			coronaTestType: .antigen,
			coronaTestService: coronaTestService,
			onUpdate: {}
		)

		XCTAssertEqual(cellModel.title, AppStrings.Home.TestResult.antigenTitle)
		XCTAssertEqual(cellModel.statusTitle, AppStrings.Home.TestResult.ShownPositive.statusTitle)
		XCTAssertEqual(cellModel.statusSubtitle, AppStrings.Home.TestResult.ShownPositive.statusSubtitle)
		XCTAssertNotNil(cellModel.statusFootnote)
		XCTAssertEqual(cellModel.noteTitle, AppStrings.Home.TestResult.ShownPositive.noteTitle)
		XCTAssertEqual(cellModel.buttonTitle, AppStrings.Home.TestResult.ShownPositive.button)
		XCTAssertFalse(cellModel.isWarnOthersButtonHidden)
		XCTAssertFalse(cellModel.isRemoveTestButtonHidden)

		let homeItemViewModels = cellModel.homeItemViewModels
		XCTAssertEqual(homeItemViewModels.count, 4)

		XCTAssertEqual(homeItemViewModels[0].title, AppStrings.Home.TestResult.ShownPositive.verifyItemTitle)
		XCTAssertEqual(homeItemViewModels[0].titleColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(homeItemViewModels[0].iconImageName, "Icons - Test Tube")
		XCTAssertEqual(homeItemViewModels[0].iconTintColor, .enaColor(for: .riskHigh))
		XCTAssertEqual(homeItemViewModels[0].color, .clear)
		XCTAssertEqual(homeItemViewModels[0].separatorColor, .clear)
		XCTAssertEqual(homeItemViewModels[0].containerInsets, .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0))

		XCTAssertEqual(homeItemViewModels[1].title, AppStrings.Home.TestResult.ShownPositive.phoneItemTitle)
		XCTAssertEqual(homeItemViewModels[1].titleColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(homeItemViewModels[1].iconImageName, "Icons - Hotline")
		XCTAssertEqual(homeItemViewModels[1].iconTintColor, .enaColor(for: .riskHigh))
		XCTAssertEqual(homeItemViewModels[1].color, .clear)
		XCTAssertEqual(homeItemViewModels[1].separatorColor, .clear)
		XCTAssertEqual(homeItemViewModels[1].containerInsets, .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0))

		XCTAssertEqual(homeItemViewModels[2].title, AppStrings.Home.TestResult.ShownPositive.homeItemTitle)
		XCTAssertEqual(homeItemViewModels[2].titleColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(homeItemViewModels[2].iconImageName, "Icons - Home")
		XCTAssertEqual(homeItemViewModels[2].iconTintColor, .enaColor(for: .riskHigh))
		XCTAssertEqual(homeItemViewModels[2].color, .clear)
		XCTAssertEqual(homeItemViewModels[2].separatorColor, .clear)
		XCTAssertEqual(homeItemViewModels[2].containerInsets, .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0))

		XCTAssertEqual(homeItemViewModels[3].title, AppStrings.Home.TestResult.ShownPositive.shareItemTitle)
		XCTAssertEqual(homeItemViewModels[3].titleColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(homeItemViewModels[3].iconImageName, "Icons - Warnen")
		XCTAssertEqual(homeItemViewModels[3].iconTintColor, .enaColor(for: .riskHigh))
		XCTAssertEqual(homeItemViewModels[3].color, .clear)
		XCTAssertEqual(homeItemViewModels[3].separatorColor, .clear)
		XCTAssertEqual(homeItemViewModels[3].containerInsets, .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0))

		coronaTestService.antigenTest?.keysSubmitted = true

		XCTAssertTrue(cellModel.isWarnOthersButtonHidden)
		XCTAssertTrue(cellModel.isRemoveTestButtonHidden)

		let newHomeItemViewModels = cellModel.homeItemViewModels
		XCTAssertEqual(newHomeItemViewModels.count, 3)

		XCTAssertEqual(newHomeItemViewModels[0].title, AppStrings.Home.TestResult.ShownPositive.verifyItemTitle)
		XCTAssertEqual(newHomeItemViewModels[0].titleColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(newHomeItemViewModels[0].iconImageName, "Icons - Test Tube")
		XCTAssertEqual(newHomeItemViewModels[0].iconTintColor, .enaColor(for: .riskHigh))
		XCTAssertEqual(newHomeItemViewModels[0].color, .clear)
		XCTAssertEqual(newHomeItemViewModels[0].separatorColor, .clear)
		XCTAssertEqual(newHomeItemViewModels[0].containerInsets, .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0))

		XCTAssertEqual(newHomeItemViewModels[1].title, AppStrings.Home.TestResult.ShownPositive.phoneItemTitle)
		XCTAssertEqual(newHomeItemViewModels[1].titleColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(newHomeItemViewModels[1].iconImageName, "Icons - Hotline")
		XCTAssertEqual(newHomeItemViewModels[1].iconTintColor, .enaColor(for: .riskHigh))
		XCTAssertEqual(newHomeItemViewModels[1].color, .clear)
		XCTAssertEqual(newHomeItemViewModels[1].separatorColor, .clear)
		XCTAssertEqual(newHomeItemViewModels[1].containerInsets, .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0))

		XCTAssertEqual(newHomeItemViewModels[2].title, AppStrings.Home.TestResult.ShownPositive.homeItemTitle)
		XCTAssertEqual(newHomeItemViewModels[2].titleColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(newHomeItemViewModels[2].iconImageName, "Icons - Home")
		XCTAssertEqual(newHomeItemViewModels[2].iconTintColor, .enaColor(for: .riskHigh))
		XCTAssertEqual(newHomeItemViewModels[2].color, .clear)
		XCTAssertEqual(newHomeItemViewModels[2].separatorColor, .clear)
		XCTAssertEqual(newHomeItemViewModels[2].containerInsets, .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0))
	}

}
