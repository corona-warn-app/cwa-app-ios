////
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

// swiftlint:disable file_length
// swiftlint:disable type_body_length
class HomeTableViewModelTests: CWATestCase {

	func testNumberOfSections_isHibernation_true_showAppClosureNotice_false() throws {
		// GIVEN
		let store = MockTestStore()

		let sut = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			appConfiguration: CachedAppConfigurationMock(),
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			cclService: FakeCCLService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
		)
		
		// WHEN

		// Is hibernation and should not show app closure notice
		sut.isHibernationState = true
		sut.shouldShowAppClosureNotice = false
		
		// THEN
		
		// Number of Sections
		XCTAssertEqual(sut.numberOfSections, 8)
				
		// Number of Rows
		XCTAssertEqual(sut.numberOfRows(in: 0), 1) // end of life tile visible
		XCTAssertEqual(sut.numberOfRows(in: 1), 0) // app closure notice invisible
		XCTAssertEqual(sut.numberOfRows(in: 2), 0) // exposure Logging invisible
		XCTAssertEqual(sut.numberOfRows(in: 3), 0) // riskAndTestResults invisible
		XCTAssertEqual(sut.numberOfRows(in: 4), 0) // testRegistration invisible
		XCTAssertEqual(sut.numberOfRows(in: 5), 1) // statistics visible
		XCTAssertEqual(sut.numberOfRows(in: 6), 0) // traceLocations invisible
		XCTAssertEqual(sut.numberOfRows(in: 7), 1) // moreInfo visible
	}
	
	func testNumberOfSections_isHibernation_true_showAppClosureNotice_true() throws {
		// GIVEN
		let store = MockTestStore()

		let sut = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			appConfiguration: CachedAppConfigurationMock(),
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			cclService: FakeCCLService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
		)
		
		// WHEN

		// Is hibernation and should show app closure notice
		sut.isHibernationState = true
		sut.shouldShowAppClosureNotice = true
		
		// THEN
		
		// Number of Sections
		XCTAssertEqual(sut.numberOfSections, 8)
				
		// Number of Rows
		XCTAssertEqual(sut.numberOfRows(in: 0), 1) // end of life tile visible
		XCTAssertEqual(sut.numberOfRows(in: 1), 0) // app closure notice invisible in hibernation although should show
		XCTAssertEqual(sut.numberOfRows(in: 2), 0) // exposure Logging invisible
		XCTAssertEqual(sut.numberOfRows(in: 3), 0) // riskAndTestResults invisible
		XCTAssertEqual(sut.numberOfRows(in: 4), 0) // testRegistration invisible
		XCTAssertEqual(sut.numberOfRows(in: 5), 1) // statistics visible
		XCTAssertEqual(sut.numberOfRows(in: 6), 0) // traceLocations invisible
		XCTAssertEqual(sut.numberOfRows(in: 7), 1) // moreInfo visible
	}
	
	func testSectionsRowsAndHeights() throws {
		let store = MockTestStore()

		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			appConfiguration: CachedAppConfigurationMock(),
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			cclService: FakeCCLService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
		)

		// Number of Sections
		XCTAssertEqual(viewModel.numberOfSections, 8)
		
		// Number of Rows
		XCTAssertEqual(viewModel.numberOfRows(in: 0), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 2), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 3), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 4), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 5), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 6), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 7), 1)

		// Check riskAndTestResultsRows
		XCTAssertEqual(viewModel.riskAndTestResultsRows, [.risk])
	}

	func testFamilyTestCellNotHiddenIfFamilyMemberTestsExist() {
		let store = MockTestStore()
		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaPcrtestParameters.hoursSinceTestRegistrationToShowRiskCard = 168
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let familyCoronaTestService = MockFamilyMemberCoronaTestService()
		familyCoronaTestService.coronaTests.value = [.antigen(.mock()), .pcr(.mock())]

		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			appConfiguration: appConfiguration,
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: familyCoronaTestService,
			cclService: FakeCCLService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 3), 2)
		XCTAssertEqual(viewModel.riskAndTestResultsRows, [.risk, .familyTestResults])
	}

	func testFamilyTestCellIsHiddenIfNoFamilyMemberTestsExist() {
		let store = MockTestStore()
		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaPcrtestParameters.hoursSinceTestRegistrationToShowRiskCard = 168
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let familyCoronaTestService = MockFamilyMemberCoronaTestService()
		familyCoronaTestService.coronaTests.value = []

		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			appConfiguration: appConfiguration,
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: familyCoronaTestService,
			cclService: FakeCCLService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 2), 1)
		XCTAssertEqual(viewModel.riskAndTestResultsRows, [.risk])
	}

	func testRiskCellNotHiddenIfPositivePCRTestResultWasNotYetShownAndLimitToShowRiskCardNotReachedAndRiskLow() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake(riskLevel: .low)
		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(calculationDate: Date(), checkinIdsWithRiskPerDate: [:], riskLevelPerDate: [:])

		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaPcrtestParameters.hoursSinceTestRegistrationToShowRiskCard = 168
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = .mock(
			registrationToken: "FAKETOKEN!",
			registrationDate: Date(timeIntervalSinceNow: -3600 * 167),
			testResult: .positive,
			positiveTestResultWasShown: false
		)

		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			appConfiguration: appConfiguration,
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			cclService: FakeCCLService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 3), 2)
		XCTAssertEqual(viewModel.riskAndTestResultsRows, [.risk, .pcrTestResult(.default)])
	}
	
	func testRiskCellHiddenIfPositivePCRTestResultWasShownAndLimitToShowRiskCardNotReachedAndRiskLow() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake(riskLevel: .low)
		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(calculationDate: Date(), checkinIdsWithRiskPerDate: [:], riskLevelPerDate: [:])

		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaPcrtestParameters.hoursSinceTestRegistrationToShowRiskCard = 168
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = .mock(
			registrationToken: "FAKETOKEN!",
			registrationDate: Date(timeIntervalSinceNow: -3600 * 167),
			testResult: .positive,
			positiveTestResultWasShown: true
		)

		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			appConfiguration: appConfiguration,
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			cclService: FakeCCLService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
		)
		
		XCTAssertEqual(viewModel.numberOfRows(in: 2), 1)
		XCTAssertEqual(viewModel.riskAndTestResultsRows, [.pcrTestResult(.positiveResultWasShown)])
	}

	func testRiskCellHiddenIfPositivePCRTestResultWasShownAndLimitToShowRiskCardNotReachedAndRiskNil() {
		let store = MockTestStore()

		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaPcrtestParameters.hoursSinceTestRegistrationToShowRiskCard = 168
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = .mock(
			registrationToken: "FAKETOKEN!",
			registrationDate: Date(timeIntervalSinceNow: -3600 * 167),
			testResult: .positive,
			positiveTestResultWasShown: true
		)

		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			appConfiguration: appConfiguration,
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			cclService: FakeCCLService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 2), 1)
		XCTAssertEqual(viewModel.riskAndTestResultsRows, [.pcrTestResult(.positiveResultWasShown)])
	}

	func testRiskCellNotHiddenIfPositivePCRTestResultWasShownAndLimitToShowRiskCardNotReachedButRiskHigh() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake(riskLevel: .high, riskLevelPerDate: [Date(): .high])
		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(calculationDate: Date(), checkinIdsWithRiskPerDate: [:], riskLevelPerDate: [:])

		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaPcrtestParameters.hoursSinceTestRegistrationToShowRiskCard = 168
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = .mock(
			registrationToken: "FAKETOKEN!",
			registrationDate: Date(timeIntervalSinceNow: -3600 * 167),
			testResult: .positive,
			positiveTestResultWasShown: true
		)

		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			appConfiguration: appConfiguration,
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			cclService: FakeCCLService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 3), 2)
		XCTAssertEqual(viewModel.riskAndTestResultsRows, [.risk, .pcrTestResult(.positiveResultWasShown)])
	}

	func testRiskCellNotHiddenIfPositivePCRTestResultWasShownAndLimitToShowRiskCardReachedAndRiskLow() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake(riskLevel: .low)
		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(calculationDate: Date(), checkinIdsWithRiskPerDate: [:], riskLevelPerDate: [:])

		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaPcrtestParameters.hoursSinceTestRegistrationToShowRiskCard = 168
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = .mock(
			registrationToken: "FAKETOKEN!",
			registrationDate: Date(timeIntervalSinceNow: -3600 * 168),
			testResult: .positive,
			positiveTestResultWasShown: true
		)

		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			appConfiguration: appConfiguration,
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			cclService: FakeCCLService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 3), 2)
		XCTAssertEqual(viewModel.riskAndTestResultsRows, [.risk, .pcrTestResult(.positiveResultWasShown)])
	}

	func testRiskCellNotHiddenIfExpiredPositivePCRTestResultWasShownAndLimitToShowRiskCardNotReachedAndRiskLow() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake(riskLevel: .low)
		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(calculationDate: Date(), checkinIdsWithRiskPerDate: [:], riskLevelPerDate: [:])

		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaPcrtestParameters.hoursSinceTestRegistrationToShowRiskCard = 168
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = .mock(
			registrationToken: "FAKETOKEN!",
			registrationDate: Date(timeIntervalSinceNow: -3600 * 167),
			testResult: .expired,
			positiveTestResultWasShown: true
		)

		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			appConfiguration: appConfiguration,
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			cclService: FakeCCLService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 3), 2)
		XCTAssertEqual(viewModel.riskAndTestResultsRows, [.risk, .pcrTestResult(.default)])
	}

	func testRiskCellNotHiddenIfExpiredPositivePCRTestResultWasShownAndLimitToShowRiskCardNotReachedAndRiskNil() {
		let store = MockTestStore()

		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaPcrtestParameters.hoursSinceTestRegistrationToShowRiskCard = 168
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = .mock(
			registrationToken: "FAKETOKEN!",
			registrationDate: Date(timeIntervalSinceNow: -3600 * 167),
			testResult: .expired,
			positiveTestResultWasShown: true
		)

		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			appConfiguration: appConfiguration,
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			cclService: FakeCCLService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 3), 2)
		XCTAssertEqual(viewModel.riskAndTestResultsRows, [.risk, .pcrTestResult(.default)])
	}

	func testRiskCellNotHiddenIfPositiveAntigenTestResultWasNotYetShownAndLimitToShowRiskCardNotReachedAndRiskLow() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake(riskLevel: .low)
		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(calculationDate: Date(), checkinIdsWithRiskPerDate: [:], riskLevelPerDate: [:])

		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaRapidAntigenTestParameters.hoursSinceSampleCollectionToShowRiskCard = 168
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let coronaTestService = MockCoronaTestService()
		coronaTestService.antigenTest.value = .mock(
			registrationToken: "FAKETOKEN!",
			sampleCollectionDate: Date(timeIntervalSinceNow: -3600 * 167),
			testResult: .positive,
			positiveTestResultWasShown: false
		)

		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			appConfiguration: appConfiguration,
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			cclService: FakeCCLService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 3), 2)
		XCTAssertEqual(viewModel.riskAndTestResultsRows, [.risk, .antigenTestResult(.default)])
	}

	func testRiskCellHiddenIfPositiveAntigenTestResultWasShownAndLimitToShowRiskCardNotReachedAndRiskLow() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake(riskLevel: .low)
		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(calculationDate: Date(), checkinIdsWithRiskPerDate: [:], riskLevelPerDate: [:])

		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaRapidAntigenTestParameters.hoursSinceSampleCollectionToShowRiskCard = 168
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let coronaTestService = MockCoronaTestService()
		coronaTestService.antigenTest.value = .mock(
			registrationToken: "FAKETOKEN!",
			sampleCollectionDate: Date(timeIntervalSinceNow: -3600 * 167),
			testResult: .positive,
			positiveTestResultWasShown: true
		)

		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			appConfiguration: appConfiguration,
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			cclService: FakeCCLService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 2), 1)
		XCTAssertEqual(viewModel.riskAndTestResultsRows, [.antigenTestResult(.positiveResultWasShown)])
	}

	func testRiskCellHiddenIfPositiveAntigenTestResultWasShownAndLimitToShowRiskCardNotReachedAndRiskNil() {
		let store = MockTestStore()

		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaRapidAntigenTestParameters.hoursSinceSampleCollectionToShowRiskCard = 168
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let coronaTestService = MockCoronaTestService()
		coronaTestService.antigenTest.value = .mock(
			registrationToken: "FAKETOKEN!",
			sampleCollectionDate: Date(timeIntervalSinceNow: -3600 * 167),
			testResult: .positive,
			positiveTestResultWasShown: true
		)

		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			appConfiguration: appConfiguration,
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			cclService: FakeCCLService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 2), 1)
		XCTAssertEqual(viewModel.riskAndTestResultsRows, [.antigenTestResult(.positiveResultWasShown)])
	}

	func testRiskCellNotHiddenIfPositiveAntigenTestResultWasShownAndLimitToShowRiskCardNotReachedButRiskHigh() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake(riskLevel: .high, riskLevelPerDate: [Date(): .high])
		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(calculationDate: Date(), checkinIdsWithRiskPerDate: [:], riskLevelPerDate: [:])

		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaRapidAntigenTestParameters.hoursSinceSampleCollectionToShowRiskCard = 168
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let coronaTestService = MockCoronaTestService()
		coronaTestService.antigenTest.value = .mock(
			registrationToken: "FAKETOKEN!",
			sampleCollectionDate: Date(timeIntervalSinceNow: -3600 * 167),
			testResult: .positive,
			positiveTestResultWasShown: true
		)

		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			appConfiguration: appConfiguration,
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			cclService: FakeCCLService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 3), 2)
		XCTAssertEqual(viewModel.riskAndTestResultsRows, [.risk, .antigenTestResult(.positiveResultWasShown)])
	}

	func testRiskCellNotHiddenIfPositiveAntigenTestResultWasShownAndLimitToShowRiskCardReachedAndRiskLow() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake(riskLevel: .low)
		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(calculationDate: Date(), checkinIdsWithRiskPerDate: [:], riskLevelPerDate: [:])

		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaRapidAntigenTestParameters.hoursSinceSampleCollectionToShowRiskCard = 168
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let coronaTestService = MockCoronaTestService()
		coronaTestService.antigenTest.value = .mock(
			registrationToken: "FAKETOKEN!",
			sampleCollectionDate: Date(timeIntervalSinceNow: -3600 * 167),
			testResult: .positive,
			positiveTestResultWasShown: false
		)

		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			appConfiguration: appConfiguration,
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			cclService: FakeCCLService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 3), 2)
		XCTAssertEqual(viewModel.riskAndTestResultsRows, [.risk, .antigenTestResult(.default)])
	}

	func testRiskCellNotHiddenIfExpiredPositiveAntigenTestResultWasShownAndLimitToShowRiskCardNotReachedAndRiskLow() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake(riskLevel: .low)
		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(calculationDate: Date(), checkinIdsWithRiskPerDate: [:], riskLevelPerDate: [:])

		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaRapidAntigenTestParameters.hoursSinceSampleCollectionToShowRiskCard = 168
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let coronaTestService = MockCoronaTestService()
		coronaTestService.antigenTest.value = .mock(
			registrationToken: "FAKETOKEN!",
			sampleCollectionDate: Date(timeIntervalSinceNow: -3600 * 167),
			testResult: .expired,
			positiveTestResultWasShown: true
		)

		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			appConfiguration: appConfiguration,
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			cclService: FakeCCLService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 3), 2)
		XCTAssertEqual(viewModel.riskAndTestResultsRows, [.risk, .antigenTestResult(.default)])
	}

	func testRiskCellNotHiddenIfExpiredPositiveAntigenTestResultWasShownAndLimitToShowRiskCardNotReachedAndRiskNil() {
		let store = MockTestStore()

		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaRapidAntigenTestParameters.hoursSinceSampleCollectionToShowRiskCard = 168
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let coronaTestService = MockCoronaTestService()
		coronaTestService.antigenTest.value = .mock(
			registrationToken: "FAKETOKEN!",
			sampleCollectionDate: Date(timeIntervalSinceNow: -3600 * 167),
			testResult: .expired,
			positiveTestResultWasShown: true
		)

		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			appConfiguration: appConfiguration,
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			cclService: FakeCCLService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 3), 2)
		XCTAssertEqual(viewModel.riskAndTestResultsRows, [.risk, .antigenTestResult(.default)])
	}

	func testRiskLoweredAlertNotSuppressedIfRiskCardIsNotHidden() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake(riskLevel: .low)
		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(calculationDate: Date(), checkinIdsWithRiskPerDate: [:], riskLevelPerDate: [:])

		store.shouldShowRiskStatusLoweredAlert = true

		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaPcrtestParameters.hoursSinceTestRegistrationToShowRiskCard = 168
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = .mock(
			registrationToken: "FAKETOKEN!",
			registrationDate: Date(timeIntervalSinceNow: -3600 * 167),
			testResult: .positive,
			positiveTestResultWasShown: false
		)

		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			appConfiguration: appConfiguration,
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			cclService: FakeCCLService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
		)

		XCTAssertFalse(viewModel.riskStatusLoweredAlertShouldBeSuppressed)
	}

	func testRiskLoweredAlertSuppressedIfRiskCardIsHidden() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake(riskLevel: .low)
		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(calculationDate: Date(), checkinIdsWithRiskPerDate: [:], riskLevelPerDate: [:])

		store.shouldShowRiskStatusLoweredAlert = true

		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaPcrtestParameters.hoursSinceTestRegistrationToShowRiskCard = 168
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = .mock(
			registrationToken: "FAKETOKEN!",
			registrationDate: Date(timeIntervalSinceNow: -3600 * 167),
			testResult: .positive,
			positiveTestResultWasShown: true
		)

		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			appConfiguration: appConfiguration,
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			cclService: FakeCCLService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
		)

		XCTAssertTrue(viewModel.riskStatusLoweredAlertShouldBeSuppressed)
	}

	func testRowHeightsWithoutStatistics() {
		let store = MockTestStore()
		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			appConfiguration: CachedAppConfigurationMock(),
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			cclService: FakeCCLService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
		)
		viewModel.state.statistics.keyFigureCards = []

		for section in HomeTableViewModel.Section.allCases.map({ $0.rawValue }) {
			for row in 0..<viewModel.numberOfRows(in: section) {
				XCTAssertEqual(
					viewModel.heightForRow(at: IndexPath(row: row, section: section)),
					section == HomeTableViewModel.Section.statistics.rawValue ? 0 : UITableView.automaticDimension
				)
			}
		}
	}

	func testRowHeightsWithStatistics() {
		let store = MockTestStore()

		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			appConfiguration: CachedAppConfigurationMock(),
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			cclService: FakeCCLService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
		)
		viewModel.state.updateStatistics()

		for section in HomeTableViewModel.Section.allCases.map({ $0.rawValue }) {
			for row in 0..<viewModel.numberOfRows(in: section) {
				XCTAssertEqual(
					viewModel.heightForRow(at: IndexPath(row: row, section: section)),
					UITableView.automaticDimension
				)
			}
		}
	}

	func testShouldShowDeletionConfirmationAlert() {
		let store = MockTestStore()

		let coronaTestService = MockCoronaTestService()

		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			appConfiguration: CachedAppConfigurationMock(),
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			cclService: FakeCCLService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
		)

		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .pcr))
		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .antigen))

		coronaTestService.pcrTest.value = nil
		coronaTestService.antigenTest.value = .mock(testResult: .expired)

		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .pcr))
		XCTAssertTrue(viewModel.shouldShowDeletionConfirmationAlert(for: .antigen))

		coronaTestService.pcrTest.value = .mock(testResult: .expired)
		coronaTestService.antigenTest.value = nil

		XCTAssertTrue(viewModel.shouldShowDeletionConfirmationAlert(for: .pcr))
		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .antigen))

		coronaTestService.pcrTest.value = .mock(testResult: .pending)
		coronaTestService.antigenTest.value = .mock(testResult: .pending)

		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .pcr))
		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .antigen))

		coronaTestService.pcrTest.value = .mock(testResult: .negative)
		coronaTestService.antigenTest.value = .mock(testResult: .negative)

		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .pcr))
		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .antigen))

		coronaTestService.pcrTest.value = .mock(testResult: .positive)
		coronaTestService.antigenTest.value = .mock(testResult: .positive)

		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .pcr))
		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .antigen))

		coronaTestService.pcrTest.value = .mock(testResult: .invalid)
		coronaTestService.antigenTest.value = .mock(testResult: .invalid)

		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .pcr))
		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .antigen))
	}

}
