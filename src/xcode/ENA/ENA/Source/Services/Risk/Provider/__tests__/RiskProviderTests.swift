//
// 🦠 Corona-Warn-App
//

import XCTest
import ExposureNotification
import HealthCertificateToolkit
@testable import ENA

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class RiskProviderTests: CWATestCase {
	
	func testGIVEN_RiskCalculation_WHEN_ENFRiskHighAndCheckinRiskLow_THEN_RiskConsumerReturnsRiskHigh() {
		// GIVEN
		let store = MockTestStore()

		let duration = DateComponents(day: 1)
		
		store.enfRiskCalculationResult = nil
		
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration
		)
		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))
		
		let cachedAppConfig = CachedAppConfigurationMock(with: SAP_Internal_V2_ApplicationConfigurationIOS())
		
		let eventStore = MockEventStore()
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			restServiceProvider: RestServiceProviderStub(),
			store: store,
			eventStore: eventStore
		)
		let today = Calendar.utcCalendar.startOfDay(for: Date())
		let riskLevelPerDateENF = [today: RiskLevel.high]
		let riskLevelPerDateCheckin = [today: RiskLevel.low]
		
		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: cachedAppConfig,
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			enfRiskCalculation: ENFRiskCalculationFake(riskLevelPerDate: riskLevelPerDateENF),
			checkinRiskCalculation: CheckinRiskCalculationFake(riskLevelPerDate: riskLevelPerDateCheckin),
			keyPackageDownload: makeKeyPackageDownloadMock(with: store),
			traceWarningPackageDownload: traceWarningPackageDownload,
			exposureDetectionExecutor: exposureDetectionDelegateStub,
			coronaTestService: MockCoronaTestService(),
			downloadedPackagesStore: DownloadedPackagesSQLLiteStore.inMemory()
		)
		
		let consumer = RiskConsumer()
		
		let didCalculateRiskExpectation = expectation(description: "expect didCalculateRisk to be called")
		
		let didFailCalculateRiskExpectation = expectation(description: "expect didFailCalculateRisk not to be called")
		didFailCalculateRiskExpectation.isInverted = true
		
		let didChangeActivityStateExpectation = expectation(description: "expect didChangeActivityState to be called 4 times")
		didChangeActivityStateExpectation.expectedFulfillmentCount = 4
		
		var risk: Risk?
		consumer.didCalculateRisk = { calculatedRisk in
			risk = calculatedRisk
			didCalculateRiskExpectation.fulfill()
		}
		consumer.didFailCalculateRisk = { _ in
			didFailCalculateRiskExpectation.fulfill()
		}
		consumer.didChangeActivityState = { _ in
			didChangeActivityStateExpectation.fulfill()
		}
		
		riskProvider.observeRisk(consumer)
		
		// WHEN
		
		riskProvider.requestRisk(userInitiated: true)
		
		// THEN
		
		waitForExpectations(timeout: .long)
		XCTAssertEqual(risk?.level, .high)
		
	}
	
	func testGIVEN_RiskCalculation_WHEN_ENFRiskLowAndCheckinRiskHigh_THEN_RiskConsumerReturnsRiskHigh() {
		// GIVEN
		let store = MockTestStore()

		let duration = DateComponents(day: 1)
		
		store.enfRiskCalculationResult = nil
		
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration
		)
		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))
		
		let cachedAppConfig = CachedAppConfigurationMock(with: SAP_Internal_V2_ApplicationConfigurationIOS())
		
		let eventStore = MockEventStore()
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			restServiceProvider: RestServiceProviderStub(),
			store: store,
			eventStore: eventStore
		)
		
		let today = Calendar.utcCalendar.startOfDay(for: Date())
		let riskLevelPerDateENF = [today: RiskLevel.low]
		let riskLevelPerDateCheckin = [today: RiskLevel.high]
		
		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: cachedAppConfig,
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			enfRiskCalculation: ENFRiskCalculationFake(riskLevelPerDate: riskLevelPerDateENF),
			checkinRiskCalculation: CheckinRiskCalculationFake(riskLevelPerDate: riskLevelPerDateCheckin),
			keyPackageDownload: makeKeyPackageDownloadMock(with: store),
			traceWarningPackageDownload: traceWarningPackageDownload,
			exposureDetectionExecutor: exposureDetectionDelegateStub,
			coronaTestService: MockCoronaTestService(),
			downloadedPackagesStore: DownloadedPackagesSQLLiteStore.inMemory()
		)
		
		let consumer = RiskConsumer()
		
		let didCalculateRiskExpectation = expectation(description: "expect didCalculateRisk to be called")
		
		let didFailCalculateRiskExpectation = expectation(description: "expect didFailCalculateRisk not to be called")
		didFailCalculateRiskExpectation.isInverted = true
		
		let didChangeActivityStateExpectation = expectation(description: "expect didChangeActivityState to be called 4 times")
		didChangeActivityStateExpectation.expectedFulfillmentCount = 4
		
		var risk: Risk?
		consumer.didCalculateRisk = { calculatedRisk in
			risk = calculatedRisk
			didCalculateRiskExpectation.fulfill()
		}
		consumer.didFailCalculateRisk = { _ in
			didFailCalculateRiskExpectation.fulfill()
		}
		consumer.didChangeActivityState = { _ in
			didChangeActivityStateExpectation.fulfill()
		}
		
		riskProvider.observeRisk(consumer)
		
		// WHEN
		
		riskProvider.requestRisk(userInitiated: true)
		
		// THEN
		
		waitForExpectations(timeout: .long)
		XCTAssertEqual(risk?.level, .high)
		
	}
	
	func testGIVEN_RiskCalculation_WHEN_ENFRiskLowAndCheckinRiskLow_THEN_RiskConsumerReturnsRiskLow() {
		// GIVEN
		let store = MockTestStore()

		let duration = DateComponents(day: 1)
		
		store.enfRiskCalculationResult = nil
		
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration
		)
		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))
		
		let cachedAppConfig = CachedAppConfigurationMock(with: SAP_Internal_V2_ApplicationConfigurationIOS())
		
		let eventStore = MockEventStore()
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			restServiceProvider: RestServiceProviderStub(),
			store: store,
			eventStore: eventStore
		)
		
		let today = Calendar.utcCalendar.startOfDay(for: Date())
		let riskLevelPerDateENF = [today: RiskLevel.low]
		let riskLevelPerDateCheckin = [today: RiskLevel.low]
		
		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: cachedAppConfig,
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			enfRiskCalculation: ENFRiskCalculationFake(riskLevelPerDate: riskLevelPerDateENF),
			checkinRiskCalculation: CheckinRiskCalculationFake(riskLevelPerDate: riskLevelPerDateCheckin),
			keyPackageDownload: makeKeyPackageDownloadMock(with: store),
			traceWarningPackageDownload: traceWarningPackageDownload,
			exposureDetectionExecutor: exposureDetectionDelegateStub,
			coronaTestService: MockCoronaTestService(),
			downloadedPackagesStore: DownloadedPackagesSQLLiteStore.inMemory()
		)
		
		let consumer = RiskConsumer()
		
		let didCalculateRiskExpectation = expectation(description: "expect didCalculateRisk to be called")
		
		let didFailCalculateRiskExpectation = expectation(description: "expect didFailCalculateRisk not to be called")
		didFailCalculateRiskExpectation.isInverted = true
		
		let didChangeActivityStateExpectation = expectation(description: "expect didChangeActivityState to be called 4 times")
		didChangeActivityStateExpectation.expectedFulfillmentCount = 4
		
		var risk: Risk?
		consumer.didCalculateRisk = { calculatedRisk in
			risk = calculatedRisk
			didCalculateRiskExpectation.fulfill()
		}
		consumer.didFailCalculateRisk = { _ in
			didFailCalculateRiskExpectation.fulfill()
		}
		consumer.didChangeActivityState = { _ in
			didChangeActivityStateExpectation.fulfill()
		}
		
		riskProvider.observeRisk(consumer)
		
		// WHEN
		
		riskProvider.requestRisk(userInitiated: true)
		
		// THEN
		
		waitForExpectations(timeout: .long)
		XCTAssertEqual(risk?.level, .low)
		
	}
	
	func testGIVEN_RiskProvider_WHEN_requestRisk_THEN_TimeoutWillTrigger() {
		// GIVEN
		let duration = DateComponents(day: 1)
		
		let store = MockTestStore()
		store.enfRiskCalculationResult = nil
		
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration
		)
		
		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))
		
		let appConfig = CachedAppConfigurationMock(with: SAP_Internal_V2_ApplicationConfigurationIOS())
		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: appConfig,
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			enfRiskCalculation: ENFRiskCalculationFake(),
			checkinRiskCalculation: CheckinRiskCalculationFake(),
			keyPackageDownload: makeKeyPackageDownloadMock(with: store),
			traceWarningPackageDownload: makeTraceWarningPackageDownloadMock(with: store, appConfig: appConfig),
			exposureDetectionExecutor: exposureDetectionDelegateStub,
			coronaTestService: MockCoronaTestService(),
			downloadedPackagesStore: DownloadedPackagesSQLLiteStore.inMemory()
		)
		
		let didCalculateRiskCalled = expectation(description: "expect didCalculateRisk to be called once")
		// this callback was unexpected - calculation doesn't gets canceled after download timeout triggered
		didCalculateRiskCalled.expectedFulfillmentCount = 1
		
		let didFailCalculateRiskCalled = expectation(description: "expect didFailCalculateRisk to be called")
		
		let consumer = RiskConsumer()
		consumer.didCalculateRisk = { _ in
			didCalculateRiskCalled.fulfill()
		}
		consumer.didFailCalculateRisk = { _ in
			didFailCalculateRiskCalled.fulfill()
		}
		
		riskProvider.observeRisk(consumer)
		
		// WHEN
		// use an timeout interval of -1 seconds to set timeout limit in the past
		riskProvider.requestRisk(userInitiated: true, timeoutInterval: TimeInterval(-1.0))
		
		// THEN
		waitForExpectations(timeout: .medium)
	}
	
	func testGIVEN_RiskProvider_WHEN_addingAndRemovingConsumer_THEN_noCallback() throws {
		let duration = DateComponents(day: 1)
		
		let store = MockTestStore()
		store.enfRiskCalculationResult = nil
		
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration
		)
		
		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))
		let cachedAppConfig = CachedAppConfigurationMock(with: SAP_Internal_V2_ApplicationConfigurationIOS())
		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: cachedAppConfig,
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			enfRiskCalculation: ENFRiskCalculationFake(),
			checkinRiskCalculation: CheckinRiskCalculationFake(),
			keyPackageDownload: makeKeyPackageDownloadMock(with: store),
			traceWarningPackageDownload: makeTraceWarningPackageDownloadMock(with: store, appConfig: cachedAppConfig),
			exposureDetectionExecutor: exposureDetectionDelegateStub,
			coronaTestService: MockCoronaTestService(),
			downloadedPackagesStore: DownloadedPackagesSQLLiteStore.inMemory()
		)
		
		let didCalculateRiskCalled = expectation(description: "expect didCalculateRisk to be called")
		didCalculateRiskCalled.isInverted = true
		
		let consumer = RiskConsumer()
		consumer.didCalculateRisk = { _ in
			XCTFail("Unexpected call")
		}
		consumer.didFailCalculateRisk = { _ in
			XCTFail("didFailCalculateRisk should not be called.")
		}
		
		riskProvider.observeRisk(consumer)
		riskProvider.removeRisk(consumer)
		riskProvider.requestRisk(userInitiated: true)
		
		waitForExpectations(timeout: .medium)
	}
	
	func testExposureDetectionIsExecutedIfLastDetectionIsTooOldAndModeIsAutomatic() throws {
		let duration = DateComponents(day: 1)
		
		let calendar = Calendar.current
		
		let lastExposureDetectionDate = try XCTUnwrap(calendar.date(
			byAdding: .day,
			value: -3,
			to: Date(),
			wrappingComponents: false
		))
		
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake(
			calculationDate: lastExposureDetectionDate
		)
		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(
			calculationDate: Date(),
			checkinIdsWithRiskPerDate: [:],
			riskLevelPerDate: [:]
		)
		
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration,
			detectionMode: .automatic
		)
		
		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))
		
		var appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		var parameters = SAP_Internal_V2_ExposureDetectionParametersIOS()
		parameters.maxExposureDetectionsPerInterval = 1
		appConfig.exposureDetectionParameters = parameters
		
		let cachedAppConfig = CachedAppConfigurationMock(with: appConfig)
		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: cachedAppConfig,
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			enfRiskCalculation: ENFRiskCalculationFake(),
			checkinRiskCalculation: CheckinRiskCalculationFake(),
			keyPackageDownload: makeKeyPackageDownloadMock(with: store),
			traceWarningPackageDownload: makeTraceWarningPackageDownloadMock(with: store, appConfig: cachedAppConfig),
			exposureDetectionExecutor: exposureDetectionDelegateStub,
			coronaTestService: MockCoronaTestService(),
			downloadedPackagesStore: DownloadedPackagesSQLLiteStore.inMemory()
		)
		
		let requestRiskExpectation = expectation(description: "")
		
		let consumer = RiskConsumer()
		riskProvider.observeRisk(consumer)
		
		consumer.didCalculateRisk = { _ in
			XCTAssertTrue(exposureDetectionDelegateStub.exposureWindowsWereDetected)
			requestRiskExpectation.fulfill()
		}
		
		riskProvider.requestRisk(userInitiated: false)
		
		waitForExpectations(timeout: .medium)
	}
	
	func testThatDetectionIsRequested() throws {
		let duration = DateComponents(day: 1)
		
		let store = MockTestStore()
		store.enfRiskCalculationResult = nil
		store.positiveTestResultWasShown = false
		store.lastSuccessfulSubmitDiagnosisKeyTimestamp = nil
		
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration
		)
		
		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))
		let appConfig = CachedAppConfigurationMock(with: SAP_Internal_V2_ApplicationConfigurationIOS())
		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: appConfig,
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			enfRiskCalculation: ENFRiskCalculationFake(),
			checkinRiskCalculation: CheckinRiskCalculationFake(),
			keyPackageDownload: makeKeyPackageDownloadMock(with: store),
			traceWarningPackageDownload: makeTraceWarningPackageDownloadMock(with: store, appConfig: appConfig),
			exposureDetectionExecutor: exposureDetectionDelegateStub,
			coronaTestService: MockCoronaTestService(),
			downloadedPackagesStore: DownloadedPackagesSQLLiteStore.inMemory()
		)
		
		let consumer = RiskConsumer()
		
		let didCalculateRiskExpectation = expectation(description: "expect didCalculateRisk to be called")
		
		let didFailCalculateRiskExpectation = expectation(description: "expect didFailCalculateRisk not to be called")
		didFailCalculateRiskExpectation.isInverted = true
		
		let didChangeActivityStateExpectation = expectation(description: "expect didChangeActivityState to be called 4 times")
		didChangeActivityStateExpectation.expectedFulfillmentCount = 4
		
		consumer.didCalculateRisk = { _ in
			didCalculateRiskExpectation.fulfill()
		}
		consumer.didFailCalculateRisk = { _ in
			didFailCalculateRiskExpectation.fulfill()
		}
		consumer.didChangeActivityState = { _ in
			didChangeActivityStateExpectation.fulfill()
		}
		
		riskProvider.observeRisk(consumer)
		riskProvider.requestRisk(userInitiated: true)
		
		waitForExpectations(timeout: .medium)
	}
	
	func testThatDetectionFails() throws {
		let duration = DateComponents(day: 1)
		
		let store = MockTestStore()
		store.enfRiskCalculationResult = nil
		store.positiveTestResultWasShown = false
		store.lastSuccessfulSubmitDiagnosisKeyTimestamp = nil
		
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration
		)
		
		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .failure(DummyError()))
		let appConfig = CachedAppConfigurationMock(with: SAP_Internal_V2_ApplicationConfigurationIOS())
		
		let sut = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: appConfig,
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			enfRiskCalculation: ENFRiskCalculationFake(),
			checkinRiskCalculation: CheckinRiskCalculationFake(),
			keyPackageDownload: makeKeyPackageDownloadMock(with: store),
			traceWarningPackageDownload: makeTraceWarningPackageDownloadMock(with: store, appConfig: appConfig),
			exposureDetectionExecutor: exposureDetectionDelegateStub,
			coronaTestService: MockCoronaTestService(),
			downloadedPackagesStore: DownloadedPackagesSQLLiteStore.inMemory()
		)
		
		let consumer = RiskConsumer()
		
		let didCalculateRiskExpectation = expectation(description: "expect didCalculateRisk to be called")
		didCalculateRiskExpectation.isInverted = true
		
		let didFailCalculateRiskExpectation = expectation(description: "expect didFailCalculateRisk not to be called")
		
		let expectedActivityStates: [RiskProviderActivityState] = [.riskRequested, .downloading, .detecting, .idle]
		let didChangeActivityStateExpectation = expectation(description: "expect didChangeActivityState to be called")
		didChangeActivityStateExpectation.expectedFulfillmentCount = expectedActivityStates.count
		
		consumer.didCalculateRisk = { _ in
			didCalculateRiskExpectation.fulfill()
		}
		
		consumer.didFailCalculateRisk = { _ in
			didFailCalculateRiskExpectation.fulfill()
		}
		
		var receivedActivityStates = [RiskProviderActivityState]()
		consumer.didChangeActivityState = {
			receivedActivityStates.append($0)
			didChangeActivityStateExpectation.fulfill()
		}
		
		sut.observeRisk(consumer)
		sut.requestRisk(userInitiated: false)
		
		waitForExpectations(timeout: .medium)
		
		XCTAssertEqual(receivedActivityStates, expectedActivityStates)
	}
	
	func testThatDetectionFails_RiskManuallyRequested() throws {
		let duration = DateComponents(day: 1)
		
		let store = MockTestStore()
		store.enfRiskCalculationResult = nil
		store.positiveTestResultWasShown = false
		store.lastSuccessfulSubmitDiagnosisKeyTimestamp = nil
		
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration
		)
		
		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .failure(DummyError()))
		let appConfig = CachedAppConfigurationMock(with: SAP_Internal_V2_ApplicationConfigurationIOS())
		
		let sut = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: appConfig,
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			enfRiskCalculation: ENFRiskCalculationFake(),
			checkinRiskCalculation: CheckinRiskCalculationFake(),
			keyPackageDownload: makeKeyPackageDownloadMock(with: store),
			traceWarningPackageDownload: makeTraceWarningPackageDownloadMock(with: store, appConfig: appConfig),
			exposureDetectionExecutor: exposureDetectionDelegateStub,
			coronaTestService: MockCoronaTestService(),
			downloadedPackagesStore: DownloadedPackagesSQLLiteStore.inMemory()
		)
		
		let consumer = RiskConsumer()
		
		let didCalculateRiskExpectation = expectation(description: "expect didCalculateRisk to be called")
		didCalculateRiskExpectation.isInverted = true
		
		let didFailCalculateRiskExpectation = expectation(description: "expect didFailCalculateRisk not to be called")
		
		let expectedActivityStates: [RiskProviderActivityState] = [.riskManuallyRequested, .downloading, .detecting, .idle]
		let didChangeActivityStateExpectation = expectation(description: "expect didChangeActivityState to be called")
		didChangeActivityStateExpectation.expectedFulfillmentCount = expectedActivityStates.count
		
		consumer.didCalculateRisk = { _ in
			didCalculateRiskExpectation.fulfill()
		}
		
		consumer.didFailCalculateRisk = { _ in
			didFailCalculateRiskExpectation.fulfill()
		}
		
		var receivedActivityStates = [RiskProviderActivityState]()
		consumer.didChangeActivityState = {
			receivedActivityStates.append($0)
			didChangeActivityStateExpectation.fulfill()
		}
		
		sut.observeRisk(consumer)
		sut.requestRisk(userInitiated: true)
		
		waitForExpectations(timeout: .medium)
		
		XCTAssertEqual(receivedActivityStates, expectedActivityStates)
	}
	
	func testShouldShowRiskStatusLoweredAlertIntitiallyFalseIsSetToTrueWhenRiskStatusLowers() throws {
		let store = MockTestStore()
		store.shouldShowRiskStatusLoweredAlert = false
		
		let riskProvider = try riskProviderChangingRiskLevel(from: .high, to: .low, store: store)
		
		let consumer = RiskConsumer()
		riskProvider.observeRisk(consumer)
		
		riskProvider.requestRisk(userInitiated: false)
		
		let didCalculateRiskExpectation = expectation(description: "didCalculateRisk called")
		consumer.didCalculateRisk = { _ in
			didCalculateRiskExpectation.fulfill()
		}
		
		waitForExpectations(timeout: .long)
		XCTAssertTrue(store.shouldShowRiskStatusLoweredAlert)
	}
	
	func testShouldShowRiskStatusLoweredAlertIntitiallyTrueIsSetToTrueWhenRiskStatusLowers() throws {
		let store = MockTestStore()
		store.shouldShowRiskStatusLoweredAlert = true
		
		let riskProvider = try riskProviderChangingRiskLevel(from: .high, to: .low, store: store)
		
		let consumer = RiskConsumer()
		riskProvider.observeRisk(consumer)
		
		riskProvider.requestRisk(userInitiated: false)
		
		let didCalculateRiskExpectation = expectation(description: "didCalculateRisk called")
		consumer.didCalculateRisk = { _ in
			didCalculateRiskExpectation.fulfill()
		}
		
		waitForExpectations(timeout: .extraLong)
		XCTAssertTrue(store.shouldShowRiskStatusLoweredAlert)
	}
	
	func testShouldShowRiskStatusLoweredAlertInitiallyFalseKeepsValueWhenRiskStatusRises() throws {
		let store = MockTestStore()
		store.shouldShowRiskStatusLoweredAlert = false
		
		let riskProvider = try riskProviderChangingRiskLevel(from: .low, to: .high, store: store)
		
		let consumer = RiskConsumer()
		riskProvider.observeRisk(consumer)
		
		riskProvider.requestRisk(userInitiated: false)
		
		let didCalculateRiskExpectation = expectation(description: "didCalculateRisk called")
		consumer.didCalculateRisk = { _ in
			didCalculateRiskExpectation.fulfill()
		}
		
		waitForExpectations(timeout: .long)
		XCTAssertFalse(store.shouldShowRiskStatusLoweredAlert)
	}
	
	func testShouldShowRiskStatusLoweredAlertInitiallyTrueIsSetToFalseWhenRiskStatusRises() throws {
		let store = MockTestStore()
		store.shouldShowRiskStatusLoweredAlert = true
		
		let riskProvider = try riskProviderChangingRiskLevel(from: .low, to: .high, store: store)
		
		let consumer = RiskConsumer()
		riskProvider.observeRisk(consumer)
		
		riskProvider.requestRisk(userInitiated: false)
		
		let didCalculateRiskExpectation = expectation(description: "didCalculateRisk called")
		consumer.didCalculateRisk = { risk in
			XCTAssertTrue(risk.riskLevelHasChanged)
			XCTAssertEqual(risk.level, .high)
			didCalculateRiskExpectation.fulfill()
		}
		
		waitForExpectations(timeout: .extraLong)
		XCTAssertFalse(store.shouldShowRiskStatusLoweredAlert)
	}
	
	func testShouldShowRiskStatusLoweredAlertInitiallyTrueKeepsValueWhenRiskStatusStaysLow() throws {
		let store = MockTestStore()
		store.shouldShowRiskStatusLoweredAlert = true
		
		let riskProvider = try riskProviderChangingRiskLevel(from: .low, to: .low, store: store)
		
		let consumer = RiskConsumer()
		riskProvider.observeRisk(consumer)
		
		riskProvider.requestRisk(userInitiated: false)
		
		let didCalculateRiskExpectation = expectation(description: "didCalculateRisk called")
		consumer.didCalculateRisk = { _ in
			didCalculateRiskExpectation.fulfill()
		}
		
		waitForExpectations(timeout: .long)
		XCTAssertTrue(store.shouldShowRiskStatusLoweredAlert)
	}
	
	func testShouldShowRiskStatusLoweredAlertInitiallyFalseKeepsValueWhenRiskStatusStaysLow() throws {
		let store = MockTestStore()
		store.shouldShowRiskStatusLoweredAlert = false
		
		let riskProvider = try riskProviderChangingRiskLevel(from: .low, to: .low, store: store)
		
		let consumer = RiskConsumer()
		riskProvider.observeRisk(consumer)
		
		riskProvider.requestRisk(userInitiated: false)
		
		let didCalculateRiskExpectation = expectation(description: "didCalculateRisk called")
		consumer.didCalculateRisk = { _ in
			didCalculateRiskExpectation.fulfill()
		}
		
		waitForExpectations(timeout: .long)
		XCTAssertFalse(store.shouldShowRiskStatusLoweredAlert)
	}
	
	func testShouldShowRiskStatusLoweredAlertInitiallyTrueKeepsValueWhenRiskStatusStaysHigh() throws {
		let store = MockTestStore()
		store.shouldShowRiskStatusLoweredAlert = true
		
		let riskProvider = try riskProviderChangingRiskLevel(from: .high, to: .high, store: store)
		
		let consumer = RiskConsumer()
		riskProvider.observeRisk(consumer)
		
		riskProvider.requestRisk(userInitiated: false)
		
		let didCalculateRiskExpectation = expectation(description: "didCalculateRisk called")
		consumer.didCalculateRisk = { _ in
			didCalculateRiskExpectation.fulfill()
		}
		
		waitForExpectations(timeout: .long)
		XCTAssertTrue(store.shouldShowRiskStatusLoweredAlert)
	}
	
	func testShouldShowRiskStatusLoweredAlertInitiallyFalseKeepsValueWhenRiskStatusStaysHigh() throws {
		let store = MockTestStore()
		store.shouldShowRiskStatusLoweredAlert = false
		
		let riskProvider = try riskProviderChangingRiskLevel(from: .high, to: .high, store: store)
		
		let consumer = RiskConsumer()
		riskProvider.observeRisk(consumer)
		
		riskProvider.requestRisk(userInitiated: false)
		
		let didCalculateRiskExpectation = expectation(description: "didCalculateRisk called")
		consumer.didCalculateRisk = { risk in
			XCTAssertFalse(risk.riskLevelHasChanged)
			XCTAssertEqual(risk.level, .high)
			didCalculateRiskExpectation.fulfill()
		}
		
		waitForExpectations(timeout: .long)
		XCTAssertFalse(store.shouldShowRiskStatusLoweredAlert)
	}
	
	// MARK: - RiskProvider stress test
	func test_When_RequestRiskIsCalledFromDifferentThreads_Then_ItReturnsWithAlreadyRunningErrorOrCalculatedRisk() {
		
		let numberOfRequestRiskCalls = 30
		let numberOfExecuteENABackgroundTask = 10
		
		let riskProvider = makeSomeRiskProvider()
		let riskConsumer = RiskConsumer()
		riskProvider.observeRisk(riskConsumer)
		
		let didCallbackExpectation = expectation(description: "Called didCalculateRisk or didFailCalculateRisk.")
		didCallbackExpectation.expectedFulfillmentCount = numberOfRequestRiskCalls + numberOfExecuteENABackgroundTask
		riskConsumer.didCalculateRisk = { _ in
			didCallbackExpectation.fulfill()
		}
		
		riskConsumer.didFailCalculateRisk = { error in
			didCallbackExpectation.fulfill()
			
			if error.isAlreadyRunningError {
				return
			}
			
			XCTFail("Error besides of isAlreadyRunningError should not happen.")
		}
		
		let concurrentQueue = DispatchQueue(label: "RiskProviderStressTest", attributes: .concurrent)
		for _ in 0...numberOfRequestRiskCalls - 1 {
			concurrentQueue.async {
				riskProvider.requestRisk(userInitiated: false)
			}
		}
		
		let appDelegate = AppDelegate()
		appDelegate.riskProvider = riskProvider
		appDelegate.store.isOnboarded = true
		
		for _ in 0...numberOfExecuteENABackgroundTask - 1 {
			appDelegate.taskExecutionDelegate.executeENABackgroundTask { _ in }
		}
		
		waitForExpectations(timeout: .extraLong)
	}
	
	
	// MARK: - Private
	
	private func makeSomeRiskProvider() -> RiskProvider {
		let duration = DateComponents(day: 1)

		let store = MockTestStore()
		store.enfRiskCalculationResult = nil
		
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration
		)
		
		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))
		
		let downloadedPackagesStore: DownloadedPackagesStore = DownloadedPackagesSQLLiteStore.inMemory()
		downloadedPackagesStore.open()
		
		let appConfig = CachedAppConfigurationMock(with: SAP_Internal_V2_ApplicationConfigurationIOS())
		
		return RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: appConfig,
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			enfRiskCalculation: ENFRiskCalculationFake(),
			checkinRiskCalculation: CheckinRiskCalculationFake(),
			keyPackageDownload: makeKeyPackageDownloadMock(with: store),
			traceWarningPackageDownload: makeTraceWarningPackageDownloadMock(with: store, appConfig: appConfig),
			exposureDetectionExecutor: exposureDetectionDelegateStub,
			coronaTestService: MockCoronaTestService(),
			downloadedPackagesStore: DownloadedPackagesSQLLiteStore.inMemory()
		)
		
	}
	
	func riskProviderChangingRiskLevel(from previousRiskLevel: RiskLevel, to newRiskLevel: RiskLevel, store: MockTestStore) throws -> RiskProvider {
		let duration = DateComponents(day: 2)
		
		let lastExposureDetectionDate = try XCTUnwrap(
			Calendar.current.date(byAdding: .day, value: -1, to: Date(), wrappingComponents: false)
		)
		
		let today = Calendar.utcCalendar.startOfDay(for: Date())
		let previousRiskLevelPerDate = [today: previousRiskLevel]
		
		store.enfRiskCalculationResult = .fake(
			riskLevel: previousRiskLevel,
			calculationDate: lastExposureDetectionDate,
			riskLevelPerDate: previousRiskLevelPerDate
		)
		
		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(
			calculationDate: Date(),
			checkinIdsWithRiskPerDate: [:],
			riskLevelPerDate: previousRiskLevelPerDate
		)
		
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration,
			detectionMode: .automatic
		)
		
		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))
		
		let appConfigurationProvider = CachedAppConfigurationMock()
		
		let downloadedPackagesStore: DownloadedPackagesStore = DownloadedPackagesSQLLiteStore .inMemory()
		downloadedPackagesStore.open()
		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: downloadedPackagesStore,
			restService: RestServiceProviderStub(),
			store: store
		)
		
		let riskLevelPerDate = [today: newRiskLevel]
		
		return RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: appConfigurationProvider,
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			enfRiskCalculation: ENFRiskCalculationFake(riskLevelPerDate: riskLevelPerDate),
			checkinRiskCalculation: CheckinRiskCalculationFake(riskLevelPerDate: riskLevelPerDate),
			keyPackageDownload: keyPackageDownload,
			traceWarningPackageDownload: makeTraceWarningPackageDownloadMock(with: store, appConfig: appConfigurationProvider),
			exposureDetectionExecutor: exposureDetectionDelegateStub,
			coronaTestService: MockCoronaTestService(),
			downloadedPackagesStore: DownloadedPackagesSQLLiteStore.inMemory()
		)
	}
	
	// MARK: - KeyPackage download
	
	func test_When_didNotDownloadNewPackages_And_LastDetectionIsLessThen24HoursAgo_Then_NoDetectionIsExecuted() throws {
		
		let calendar = Calendar.current
		
		let lastExposureDetectionDate = try XCTUnwrap(calendar.date(
			byAdding: .hour,
			value: -12,
			to: Date(),
			wrappingComponents: false
		))
		
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake(
			calculationDate: lastExposureDetectionDate
		)
		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(
			calculationDate: Date(),
			checkinIdsWithRiskPerDate: [:],
			riskLevelPerDate: [:]
		)
		
		store.lastKeyPackageDownloadDate = .distantPast
		
		let exposureDetectionsInterval = 6
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: DateComponents(day: 1),
			exposureDetectionInterval: DateComponents(hour: 24 / exposureDetectionsInterval),
			detectionMode: .automatic
		)
		
		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))
		
		let downloadedPackagesStore: DownloadedPackagesStore = DownloadedPackagesSQLLiteStore .inMemory()
		downloadedPackagesStore.open()
		
		let client = ClientMock()
		client.fetchPackageRequestFailure = URLSession.Response.Failure.noResponse
		
		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: downloadedPackagesStore,
			restService: RestServiceProviderStub(),
			store: store
		)
		
		var appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		var parameters = SAP_Internal_V2_ExposureDetectionParametersIOS()
		parameters.maxExposureDetectionsPerInterval = 6
		appConfig.exposureDetectionParameters = parameters
		let cachedAppConfig = CachedAppConfigurationMock(with: appConfig)
		
		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: cachedAppConfig,
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			enfRiskCalculation: ENFRiskCalculationFake(),
			checkinRiskCalculation: CheckinRiskCalculationFake(),
			keyPackageDownload: keyPackageDownload,
			traceWarningPackageDownload: makeTraceWarningPackageDownloadMock(with: store, appConfig: cachedAppConfig),
			exposureDetectionExecutor: exposureDetectionDelegateStub,
			coronaTestService: MockCoronaTestService(),
			downloadedPackagesStore: DownloadedPackagesSQLLiteStore.inMemory()
		)
		
		let requestRiskExpectation = expectation(description: "")
		
		let consumer = RiskConsumer()
		riskProvider.observeRisk(consumer)
		
		consumer.didCalculateRisk = { _ in
			XCTAssertFalse(exposureDetectionDelegateStub.exposureWindowsWereDetected)
			requestRiskExpectation.fulfill()
		}
		
		riskProvider.requestRisk(userInitiated: false)
		
		waitForExpectations(timeout: .medium)
	}
	
	func test_When_didDownloadNewPackages_And_LastDetectionIsLessThen24HoursAgo_Then_DetectionIsExecuted() throws {
		
		let calendar = Calendar.current
		
		let lastExposureDetectionDate = try XCTUnwrap(calendar.date(
			byAdding: .hour,
			value: -12,
			to: Date(),
			wrappingComponents: false
		))
		
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake(
			calculationDate: lastExposureDetectionDate
		)
		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(
			calculationDate: Date(),
			checkinIdsWithRiskPerDate: [:],
			riskLevelPerDate: [:]
		)
		
		let exposureDetectionsInterval = 6
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: DateComponents(day: 1),
			exposureDetectionInterval: DateComponents(hour: 24 / exposureDetectionsInterval),
			detectionMode: .automatic
		)
		
		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))
		
		let downloadedPackagesStore: DownloadedPackagesStore = DownloadedPackagesSQLLiteStore .inMemory()
		downloadedPackagesStore.open()
		
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(["2020-10-02", "2020-10-01", "2020-10-03", "2020-10-04"]),
				.success([1, 2])
			]
		)

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: downloadedPackagesStore,
			restService: restServiceProvider,
			store: store
		)
		
		var appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		var parameters = SAP_Internal_V2_ExposureDetectionParametersIOS()
		parameters.maxExposureDetectionsPerInterval = 6
		appConfig.exposureDetectionParameters = parameters
		let cachedAppConfig = CachedAppConfigurationMock(with: appConfig)
		
		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: cachedAppConfig,
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			enfRiskCalculation: ENFRiskCalculationFake(),
			checkinRiskCalculation: CheckinRiskCalculationFake(),
			keyPackageDownload: keyPackageDownload,
			traceWarningPackageDownload: makeTraceWarningPackageDownloadMock(with: store, appConfig: cachedAppConfig),
			exposureDetectionExecutor: exposureDetectionDelegateStub,
			coronaTestService: MockCoronaTestService(),
			downloadedPackagesStore: DownloadedPackagesSQLLiteStore.inMemory()
		)
		
		let requestRiskExpectation = expectation(description: "")
		
		let consumer = RiskConsumer()
		riskProvider.observeRisk(consumer)
		
		consumer.didCalculateRisk = { _ in
			XCTAssertTrue(exposureDetectionDelegateStub.exposureWindowsWereDetected)
			requestRiskExpectation.fulfill()
		}
		
		riskProvider.requestRisk(userInitiated: false)
		
		waitForExpectations(timeout: .medium)
	}
	
	func test_When_didNotDownloadNewPackages_And_LastDetectionIsMoreThen24HoursAgo_Then_DetectionIsExecuted() throws {
		
		let calendar = Calendar.current
		
		let lastExposureDetectionDate = try XCTUnwrap(calendar.date(
			byAdding: .hour,
			value: -25,
			to: Date(),
			wrappingComponents: false
		))
		
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake(
			calculationDate: lastExposureDetectionDate
		)
		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(
			calculationDate: Date(),
			checkinIdsWithRiskPerDate: [:],
			riskLevelPerDate: [:]
		)
		
		store.lastKeyPackageDownloadDate = .distantPast
		
		let exposureDetectionsInterval = 6
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: DateComponents(day: 1),
			exposureDetectionInterval: DateComponents(hour: 24 / exposureDetectionsInterval),
			detectionMode: .automatic
		)
		
		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))
		
		let downloadedPackagesStore: DownloadedPackagesStore = DownloadedPackagesSQLLiteStore .inMemory()
		downloadedPackagesStore.open()
		
		let client = ClientMock()
		client.fetchPackageRequestFailure = URLSession.Response.Failure.noResponse
		
		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: downloadedPackagesStore,
			restService: RestServiceProviderStub(),
			store: store
		)
		
		var appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		var parameters = SAP_Internal_V2_ExposureDetectionParametersIOS()
		parameters.maxExposureDetectionsPerInterval = 6
		appConfig.exposureDetectionParameters = parameters
		let cachedAppConfig = CachedAppConfigurationMock(with: appConfig)
		
		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: cachedAppConfig,
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			enfRiskCalculation: ENFRiskCalculationFake(),
			checkinRiskCalculation: CheckinRiskCalculationFake(),
			keyPackageDownload: keyPackageDownload,
			traceWarningPackageDownload: makeTraceWarningPackageDownloadMock(with: store, appConfig: cachedAppConfig),
			exposureDetectionExecutor: exposureDetectionDelegateStub,
			coronaTestService: MockCoronaTestService(),
			downloadedPackagesStore: DownloadedPackagesSQLLiteStore.inMemory()
		)
		
		let requestRiskExpectation = expectation(description: "")
		
		let consumer = RiskConsumer()
		riskProvider.observeRisk(consumer)
		
		consumer.didCalculateRisk = { _ in
			XCTAssertTrue(exposureDetectionDelegateStub.exposureWindowsWereDetected)
			requestRiskExpectation.fulfill()
		}
		
		riskProvider.requestRisk(userInitiated: false)
		
		waitForExpectations(timeout: .medium)
	}
	
	func test_When_didDownloadNewPackages_And_LastDetectionIsMoreThen24HoursAgo_Then_DetectionIsExecuted() throws {
		
		let calendar = Calendar.current
		
		let lastExposureDetectionDate = try XCTUnwrap(calendar.date(
			byAdding: .hour,
			value: -25,
			to: Date(),
			wrappingComponents: false
		))
		
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake(
			calculationDate: lastExposureDetectionDate
		)
		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(
			calculationDate: Date(),
			checkinIdsWithRiskPerDate: [:],
			riskLevelPerDate: [:]
		)
		
		let exposureDetectionsInterval = 6
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: DateComponents(day: 1),
			exposureDetectionInterval: DateComponents(hour: 24 / exposureDetectionsInterval),
			detectionMode: .automatic
		)
		
		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))
		
		let downloadedPackagesStore: DownloadedPackagesStore = DownloadedPackagesSQLLiteStore .inMemory()
		downloadedPackagesStore.open()
		
		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: downloadedPackagesStore,
			restService: RestServiceProviderStub(),
			store: store
		)
		
		var appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		var parameters = SAP_Internal_V2_ExposureDetectionParametersIOS()
		parameters.maxExposureDetectionsPerInterval = 6
		appConfig.exposureDetectionParameters = parameters
		let cachedAppConfig = CachedAppConfigurationMock(with: appConfig)
		
		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: cachedAppConfig,
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			enfRiskCalculation: ENFRiskCalculationFake(),
			checkinRiskCalculation: CheckinRiskCalculationFake(),
			keyPackageDownload: keyPackageDownload,
			traceWarningPackageDownload: makeTraceWarningPackageDownloadMock(with: store, appConfig: cachedAppConfig),
			exposureDetectionExecutor: exposureDetectionDelegateStub,
			coronaTestService: MockCoronaTestService(),
			downloadedPackagesStore: DownloadedPackagesSQLLiteStore.inMemory()
		)
		
		let requestRiskExpectation = expectation(description: "")
		
		let consumer = RiskConsumer()
		riskProvider.observeRisk(consumer)
		
		consumer.didCalculateRisk = { _ in
			XCTAssertTrue(exposureDetectionDelegateStub.exposureWindowsWereDetected)
			requestRiskExpectation.fulfill()
		}
		
		riskProvider.requestRisk(userInitiated: false)
		
		waitForExpectations(timeout: .medium)
	}
	
	func test_WhenExposureWindowsRetievalIsSuccessful_TheyShouldBeAddedToTheMetadata() throws {
		let store = MockTestStore()
		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		XCTAssertNil(store.exposureWindowsMetadata, "The exposureWindowsMetadata should be initially nil")
		
		let riskProvider = try riskProviderChangingRiskLevel(from: .high, to: .high, store: store)
		
		let consumer = RiskConsumer()
		riskProvider.observeRisk(consumer)
		riskProvider.requestRisk(userInitiated: false)
		
		let didCalculateRiskExpectation = expectation(description: "didCalculateRisk called")
		consumer.didCalculateRisk = { _ in
			guard let newWindowsMetadata = store.exposureWindowsMetadata else {
				XCTFail("Windows metadata should be initialized")
				return
			}
			XCTAssertFalse(newWindowsMetadata.newExposureWindowsQueue.isEmpty, "newExposureWindowsQueue should be populated")
			XCTAssertFalse(newWindowsMetadata.reportedExposureWindowsQueue.isEmpty, "reportedExposureWindowsQueue should be populated")
			didCalculateRiskExpectation.fulfill()
		}
		
		waitForExpectations(timeout: .long)
	}
}

class ENFRiskCalculationFake: ENFRiskCalculationProtocol {
	
	init(
		riskLevelPerDate: [Date: RiskLevel]? = nil
	) {
		if let riskLevelPerDate = riskLevelPerDate {
			self.riskLevelPerDate = riskLevelPerDate
			guard let riskLevel = riskLevelPerDate.first?.value else {
				XCTFail("Could not retrieve first value for risklevel")
				self.riskLevel = .low
				return
			}
			self.riskLevel = riskLevel
		} else {
			let today = Calendar.utcCalendar.startOfDay(for: Date())
			self.riskLevel = RiskLevel.low
			self.riskLevelPerDate = [today: riskLevel]
		}
	}
	
	let riskLevel: RiskLevel
	let riskLevelPerDate: [Date: RiskLevel]
	
	func calculateRisk(
		exposureWindows: [ExposureWindow],
		configuration: RiskCalculationConfiguration
	) -> ENFRiskCalculationResult {
		mappedExposureWindows = exposureWindows.map({ RiskCalculationExposureWindow(exposureWindow: $0, configuration: configuration) })
		
		return .fake(
			riskLevel: riskLevel,
			calculationDate: Date(),
			riskLevelPerDate: riskLevelPerDate
		)
	}
	
	var mappedExposureWindows: [RiskCalculationExposureWindow] = []
}

class CheckinRiskCalculationFake: CheckinRiskCalculationProtocol {
	
	init(
		riskLevelPerDate: [Date: RiskLevel] = [Date(): .low]
	) {
		self.riskLevelPerDate = riskLevelPerDate
	}
	
	let riskLevelPerDate: [Date: RiskLevel]
	
	func calculateRisk(
		with config: SAP_Internal_V2_ApplicationConfigurationIOS,
		now: Date = Date()
	) -> CheckinRiskCalculationResult {
		return CheckinRiskCalculationResult(calculationDate: Date(), checkinIdsWithRiskPerDate: [Date: [CheckinIdWithRisk]](), riskLevelPerDate: riskLevelPerDate)
	}
}

extension CWATestCase {
	func makeKeyPackageDownloadMock(with store: Store) -> KeyPackageDownload {
		let downloadedPackagesStore: DownloadedPackagesStore = DownloadedPackagesSQLLiteStore.inMemory()
		downloadedPackagesStore.open()

		let restServiceProvider = RestServiceProviderStub(
				results: [
					.success(["day"]),
					.success([0])
				])


		return KeyPackageDownload(
			downloadedPackagesStore: downloadedPackagesStore,
			restService: restServiceProvider,
			store: store
		)
	}

	func makeTraceWarningPackageDownloadMock(with store: Store, appConfig: CachedAppConfigurationMock) -> TraceWarningPackageDownload {
		let mockEventStore = MockEventStore()
		return TraceWarningPackageDownload(
			restServiceProvider: RestServiceProviderStub(),
			store: store,
			eventStore: mockEventStore
		)
	}
}

final class ExposureDetectionDelegateStub: ExposureDetectionDelegate {
	
	private let result: Result<[ENExposureWindow], Error>
	private let keyPackagesToWrite: WrittenPackages
	
	var exposureWindowsWereDetected = false
	
	init(
		result: Result<[ENExposureWindow], Error>,
		keyPackagesToWrite: WrittenPackages = ExposureDetectionDelegateStub.defaultKeyPackages) {
			self.result = result
			self.keyPackagesToWrite = keyPackagesToWrite
		}
	
	func exposureDetectionWriteDownloadedPackages(country: Country.ID) -> WrittenPackages? {
		return keyPackagesToWrite
	}
	
	func detectExposureWindows(_ detection: ExposureDetection, detectSummaryWithConfiguration configuration: ENExposureConfiguration, writtenPackages: WrittenPackages, completion: @escaping (Result<[ENExposureWindow], Error>) -> Void) -> Progress {
		exposureWindowsWereDetected = true
		completion(result)
		return Progress()
	}
	
	static var defaultKeyPackages: WrittenPackages {
		guard let rootDir = try? ExposureDetectionDelegateStub.createRootDirectory() else {
			fatalError("Could not create root directory.")
		}
		let writer = AppleFilesWriter(rootDir: rootDir)
		
		let dummyPackage = SAPDownloadedPackage(keysBin: Data(), signature: Data())
		_ = writer.writePackage(dummyPackage)
		return writer.writtenPackages
	}
	
	static func createRootDirectory() throws -> URL {
		let fm = FileManager()
		let tempDir = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
		
		try fm.createDirectory(
			atPath: tempDir.path,
			withIntermediateDirectories: true,
			attributes: nil
		)
		return tempDir
	}
}

struct DummyError: Error { }
