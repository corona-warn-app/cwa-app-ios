//
// 🦠 Corona-Warn-App
//

import XCTest
import ExposureNotification
import HealthCertificateToolkit
@testable import ENA

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
final class RiskProviderTests: CWATestCase {
	
	func testGIVEN_RiskCalculation_WHEN_ENFRiskHighAndCheckinRiskLow_THEN_RiskConsumerReturnsRiskHigh() {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		
		let duration = DateComponents(day: 1)

		store.enfRiskCalculationResult = nil

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration
		)
		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))
		
		let appConfig = CachedAppConfigurationMock(with: SAP_Internal_V2_ApplicationConfigurationIOS())

		let eventStore = MockEventStore()
		let traceWarningPackageDownload = TraceWarningPackageDownload(
		   client: client,
		   store: store,
		   eventStore: eventStore
	   )
		let today = Calendar.utcCalendar.startOfDay(for: Date())
		let riskLevelPerDateENF = [today: RiskLevel.high]
		let riskLevelPerDateCheckin = [today: RiskLevel.low]
		
		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: appConfig,
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			enfRiskCalculation: ENFRiskCalculationFake(riskLevelPerDate: riskLevelPerDateENF),
			checkinRiskCalculation: CheckinRiskCalculationFake(riskLevelPerDate: riskLevelPerDateCheckin),
			keyPackageDownload: makeKeyPackageDownloadMock(with: store),
			traceWarningPackageDownload: traceWarningPackageDownload,
			exposureDetectionExecutor: exposureDetectionDelegateStub,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: eventStore,
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfig,
				healthCertificateService: HealthCertificateService(
					store: store,
					signatureVerifying: DCCSignatureVerifyingStub(),
					client: client,
					appConfiguration: appConfig
				)
			)
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
		let client = ClientMock()
		
		let duration = DateComponents(day: 1)

		store.enfRiskCalculationResult = nil

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration
		)
		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))
		
		let appConfig = CachedAppConfigurationMock(with: SAP_Internal_V2_ApplicationConfigurationIOS())

		let eventStore = MockEventStore()
		let traceWarningPackageDownload = TraceWarningPackageDownload(
		   client: client,
		   store: store,
		   eventStore: eventStore
	   )
		let today = Calendar.utcCalendar.startOfDay(for: Date())
		let riskLevelPerDateENF = [today: RiskLevel.low]
		let riskLevelPerDateCheckin = [today: RiskLevel.high]
		
		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: appConfig,
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			enfRiskCalculation: ENFRiskCalculationFake(riskLevelPerDate: riskLevelPerDateENF),
			checkinRiskCalculation: CheckinRiskCalculationFake(riskLevelPerDate: riskLevelPerDateCheckin),
			keyPackageDownload: makeKeyPackageDownloadMock(with: store),
			traceWarningPackageDownload: traceWarningPackageDownload,
			exposureDetectionExecutor: exposureDetectionDelegateStub,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: eventStore,
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfig,
				healthCertificateService: HealthCertificateService(
					store: store,
					signatureVerifying: DCCSignatureVerifyingStub(),
					client: client,
					appConfiguration: appConfig
				)
			)
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
		let client = ClientMock()
		
		let duration = DateComponents(day: 1)

		store.enfRiskCalculationResult = nil

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration
		)
		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))
		
		let appConfig = CachedAppConfigurationMock(with: SAP_Internal_V2_ApplicationConfigurationIOS())

		let eventStore = MockEventStore()
		let traceWarningPackageDownload = TraceWarningPackageDownload(
		   client: client,
		   store: store,
		   eventStore: eventStore
	   )
		let today = Calendar.utcCalendar.startOfDay(for: Date())
		let riskLevelPerDateENF = [today: RiskLevel.low]
		let riskLevelPerDateCheckin = [today: RiskLevel.low]
		
		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: appConfig,
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			enfRiskCalculation: ENFRiskCalculationFake(riskLevelPerDate: riskLevelPerDateENF),
			checkinRiskCalculation: CheckinRiskCalculationFake(riskLevelPerDate: riskLevelPerDateCheckin),
			keyPackageDownload: makeKeyPackageDownloadMock(with: store),
			traceWarningPackageDownload: traceWarningPackageDownload,
			exposureDetectionExecutor: exposureDetectionDelegateStub,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: eventStore,
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfig,
				healthCertificateService: HealthCertificateService(
					store: store,
					signatureVerifying: DCCSignatureVerifyingStub(),
					client: client,
					appConfiguration: appConfig
				)
			)
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

		let client = ClientMock()
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
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfig,
				healthCertificateService: HealthCertificateService(
					store: store,
					signatureVerifying: DCCSignatureVerifyingStub(),
					client: client,
					appConfiguration: appConfig
				)
			)
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
		// use an timeout interval of -1 secounds to set timeout limit in the past
		riskProvider.requestRisk(userInitiated: true, timeoutInterval: TimeInterval(-1.0))

		// THEN
		waitForExpectations(timeout: .medium)
	}

	func testGIVEN_RiskProvider_WHEN_addingAndRemovingConsumer_THEN_noCallback() throws {
		let duration = DateComponents(day: 1)

		let client = ClientMock()
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
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: cachedAppConfig,
				healthCertificateService: HealthCertificateService(
					store: store,
					signatureVerifying: DCCSignatureVerifyingStub(),
					client: client,
					appConfiguration: cachedAppConfig
				)
			)
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

		let client = ClientMock()
		let store = MockTestStore()
		store.enfRiskCalculationResult = ENFRiskCalculationResult(
			riskLevel: .low,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: nil,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 0,
			calculationDate: lastExposureDetectionDate,
			riskLevelPerDate: [:],
			minimumDistinctEncountersWithHighRiskPerDate: [:]
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
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: cachedAppConfig,
				healthCertificateService: HealthCertificateService(
					store: store,
					signatureVerifying: DCCSignatureVerifyingStub(),
					client: client,
					appConfiguration: cachedAppConfig
				)
			)
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

		let client = ClientMock()
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
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfig,
				healthCertificateService: HealthCertificateService(
					store: store,
					signatureVerifying: DCCSignatureVerifyingStub(),
					client: client,
					appConfiguration: appConfig
				)
			)
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

		let client = ClientMock()
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
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfig,
				healthCertificateService: HealthCertificateService(
					store: store,
					signatureVerifying: DCCSignatureVerifyingStub(),
					client: client,
					appConfiguration: appConfig
				)
			)
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
		sut.requestRisk(userInitiated: true)
		
		waitForExpectations(timeout: .medium)

		XCTAssertEqual(receivedActivityStates, expectedActivityStates)
	}

	func testThatDetectionIsNotRequestedIfPositiveTestResultWasShown() throws {
		let duration = DateComponents(day: 1)

		let client = ClientMock()
		let store = MockTestStore()

		store.enfRiskCalculationResult = nil
		store.pcrTest = PCRTest.mock(positiveTestResultWasShown: true)

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
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfig,
				healthCertificateService: HealthCertificateService(
					store: store,
					signatureVerifying: DCCSignatureVerifyingStub(),
					client: client,
					appConfiguration: appConfig
				)
			)
		)

		let consumer = RiskConsumer()

		let didCalculateRiskExpectation = expectation(description: "expect didCalculateRisk not to be called")
		didCalculateRiskExpectation.isInverted = true

		let didFailCalculateRiskExpectation = expectation(description: "expect didFailCalculateRisk to be called")

		let expectedActivityStates: [RiskProviderActivityState] = [.onlyDownloadsRequested, .downloading, .idle]
		let didChangeActivityStateExpectation = expectation(description: "expect didChangeActivityState to be called")
		didChangeActivityStateExpectation.expectedFulfillmentCount = expectedActivityStates.count

		consumer.didCalculateRisk = { _ in
			didCalculateRiskExpectation.fulfill()
		}

		consumer.didFailCalculateRisk = { error in
			// Make sure that exposure windows where NOT requested.
			XCTAssertFalse(exposureDetectionDelegateStub.exposureWindowsWereDetected)

			guard case .deactivatedDueToActiveTest = error else {
				XCTFail("deactivatedDueToActiveTest error expected.")
				didFailCalculateRiskExpectation.fulfill()
				return
			}
			didFailCalculateRiskExpectation.fulfill()
		}

		var receivedActivityStates = [RiskProviderActivityState]()
		consumer.didChangeActivityState = {
			receivedActivityStates.append($0)
			didChangeActivityStateExpectation.fulfill()
		}

		riskProvider.observeRisk(consumer)
		riskProvider.requestRisk(userInitiated: true)

		waitForExpectations(timeout: .medium)

		XCTAssertEqual(receivedActivityStates, expectedActivityStates)
	}

	func testThatDetectionIsNotRequestedIfKeysWereSubmitted() throws {
		let duration = DateComponents(day: 1)

		let client = ClientMock()
		let store = MockTestStore()
		store.enfRiskCalculationResult = nil
		store.pcrTest = PCRTest.mock(keysSubmitted: true)

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
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfig,
				healthCertificateService: HealthCertificateService(
					store: store,
					signatureVerifying: DCCSignatureVerifyingStub(),
					client: client,
					appConfiguration: appConfig
				)
			)
		)

		let consumer = RiskConsumer()

		let didCalculateRiskExpectation = expectation(description: "expect didCalculateRisk not to be called")
		didCalculateRiskExpectation.isInverted = true

		let didFailCalculateRiskExpectation = expectation(description: "expect didFailCalculateRisk to be called")

		let expectedActivityStates: [RiskProviderActivityState] = [.onlyDownloadsRequested, .downloading, .idle]
		let didChangeActivityStateExpectation = expectation(description: "expect didChangeActivityState to be called")
		didChangeActivityStateExpectation.expectedFulfillmentCount = expectedActivityStates.count

		consumer.didCalculateRisk = { _ in
			didCalculateRiskExpectation.fulfill()
		}

		consumer.didFailCalculateRisk = { error in
			// Make sure that exposure windows where NOT requested.
			XCTAssertFalse(exposureDetectionDelegateStub.exposureWindowsWereDetected)

			guard case .deactivatedDueToActiveTest = error else {
				XCTFail("deactivatedDueToActiveTest error expected.")
				didFailCalculateRiskExpectation.fulfill()
				return
			}
			didFailCalculateRiskExpectation.fulfill()
		}

		var receivedActivityStates = [RiskProviderActivityState]()
		consumer.didChangeActivityState = {
			receivedActivityStates.append($0)
			didChangeActivityStateExpectation.fulfill()
		}

		riskProvider.observeRisk(consumer)
		riskProvider.requestRisk(userInitiated: true)

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

		waitForExpectations(timeout: .long)
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

		waitForExpectations(timeout: .long)
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

	// MARK: - Test the rate limitation
	func test_GIVEN_EnfSucceededNoWindows_WHEN_RiskRequestedAgain_THEN_RateLimitIsEffective() throws {
		// setup
		// setup
		let store = MockTestStore()
		let builder = RiskProviderBuilder()

		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.exposureDetectionParameters.maxExposureDetectionsPerInterval = 6
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)
		builder.configureAppConfig(appConfig: appConfiguration)

		let calendar = Calendar.current
		let previousExposureDetectionDate = try XCTUnwrap(calendar.date(
			byAdding: .hour,
			value: -5,
			to: Date(),
			wrappingComponents: false
		))
		store.enfRiskCalculationResult = makeEnfRiskCalculationResultMock(withCalculationDate: previousExposureDetectionDate)
		store.checkinRiskCalculationResult = makeCheckinRiskCalculationResult()
		builder.configureStore(store: store)

		let exposureDetectionDelegate = ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))
		builder.configureExposureDetection(delegate: exposureDetectionDelegate)

		let riskProvider = builder.build()
		let riskConsumer = RiskConsumer()
		riskProvider.observeRisk(riskConsumer)

		// pre-conditions
		let expectPrecondition = expectation(description: "Precondition: a succeeded risk calculation.")
		riskConsumer.didCalculateRisk = { _ in
			// GIVEN - a succeeded risk calculation
			expectPrecondition.fulfill()
			XCTAssertEqual(exposureDetectionDelegate.numberOfDetectionCalls, 1, "Exposure detection should have been called")
		}

		riskProvider.requestRisk(userInitiated: false)
		waitForExpectations(timeout: .medium)
		XCTAssertNotEqual(store.enfRiskCalculationResult?.calculationDate, previousExposureDetectionDate, "Risk calculation date should change")

		// test scenario
		let lastRiskCalculationtionDate = store.enfRiskCalculationResult?.calculationDate
		let expectRiskResult = expectation(description: "Risk result is provided")
		riskConsumer.didCalculateRisk = { _ in
			// THEN - risk level is provided without calling the exposure detection again
			expectRiskResult.fulfill()
			XCTAssertEqual(exposureDetectionDelegate.numberOfDetectionCalls, 1, "Exposure detection should not have been called again")
		}
		riskConsumer.didFailCalculateRisk = { _ in
			XCTFail("Risk should be provided")
		}

		// WHEN - request risk again
		riskProvider.requestRisk(userInitiated: false)
		waitForExpectations(timeout: .medium)

		XCTAssertEqual(store.enfRiskCalculationResult?.calculationDate, lastRiskCalculationtionDate, "Risk calculation timestamp should not change")
	}

	func test_GIVEN_EnfFailed_WHEN_RiskRequestedAgain_THEN_RateLimitIsEffective() throws {
		// setup
		let store = MockTestStore()
		let builder = RiskProviderBuilder()

		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.exposureDetectionParameters.maxExposureDetectionsPerInterval = 6
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)
		builder.configureAppConfig(appConfig: appConfiguration)

		let calendar = Calendar.current
		let previousExposureDetectionDate = try XCTUnwrap(calendar.date(
			byAdding: .hour,
			value: -5,
			to: Date(),
			wrappingComponents: false
		))
		store.enfRiskCalculationResult = makeEnfRiskCalculationResultMock(withCalculationDate: previousExposureDetectionDate)
		store.checkinRiskCalculationResult = makeCheckinRiskCalculationResult()
		builder.configureStore(store: store)
		
		let exposureDetectionDelegate = ExposureDetectionDelegateStub(result: .failure(ENError(.internal)))
		builder.configureExposureDetection(delegate: exposureDetectionDelegate)
		
		let riskProvider = builder.build()
		let riskConsumer = RiskConsumer()
		riskProvider.observeRisk(riskConsumer)

		// pre-conditions
		let expectPrecondition = expectation(description: "Precondition: a failed risk calculation.")
		riskConsumer.didFailCalculateRisk = { _ in
			// GIVEN - a failed risk calculation
			expectPrecondition.fulfill()
			XCTAssertEqual(exposureDetectionDelegate.numberOfDetectionCalls, 1, "Exposure detection should have been called")
		}

		riskProvider.requestRisk(userInitiated: false)
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(store.enfRiskCalculationResult?.calculationDate, previousExposureDetectionDate, "Risk calculation date should not change")

		// test scenario
		let lastRiskCalculationtionDate = store.enfRiskCalculationResult?.calculationDate

		let expectRiskResult = expectation(description: "Risk result is provided")
		riskConsumer.didCalculateRisk = { _ in
			// THEN - risk level is provided without calling the exposure detection again
			expectRiskResult.fulfill()
			XCTAssertEqual(exposureDetectionDelegate.numberOfDetectionCalls, 1, "Exposure detection should not have been called again")
		}
		riskConsumer.didFailCalculateRisk = { _ in
			XCTFail("Risk should be provided")
		}

		// WHEN - request risk again
		riskProvider.requestRisk(userInitiated: false)
		waitForExpectations(timeout: .medium)

		XCTAssertEqual(store.enfRiskCalculationResult?.calculationDate, lastRiskCalculationtionDate, "Risk calculation timestamp should not change")
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

		for _ in 0...numberOfExecuteENABackgroundTask - 1 {
			appDelegate.taskExecutionDelegate.executeENABackgroundTask { _ in }
		}

		waitForExpectations(timeout: .extraLong)
	}


	// MARK: - Private

	private func makeSomeRiskProvider() -> RiskProvider {
		let duration = DateComponents(day: 1)

		let client = ClientMock()

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
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfig,
				healthCertificateService: HealthCertificateService(
					store: store,
					signatureVerifying: DCCSignatureVerifyingStub(),
					client: client,
					appConfiguration: appConfig
				)
			)
		)
	
	}

	private func riskProviderChangingRiskLevel(from previousRiskLevel: RiskLevel, to newRiskLevel: RiskLevel, store: MockTestStore) throws -> RiskProvider {
		let duration = DateComponents(day: 2)

		let lastExposureDetectionDate = try XCTUnwrap(
			Calendar.current.date(byAdding: .day, value: -1, to: Date(), wrappingComponents: false)
		)

		let today = Calendar.utcCalendar.startOfDay(for: Date())
		let previousRiskLevelPerDate = [today: previousRiskLevel]
		
		store.enfRiskCalculationResult = ENFRiskCalculationResult(
			riskLevel: previousRiskLevel,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: nil,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 0,
			calculationDate: lastExposureDetectionDate,
			riskLevelPerDate: previousRiskLevelPerDate,
			minimumDistinctEncountersWithHighRiskPerDate: [:]
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
		let client = ClientMock()
		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: downloadedPackagesStore,
			client: client,
			wifiClient: client,
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
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfigurationProvider,
				healthCertificateService: HealthCertificateService(
					store: store,
					signatureVerifying: DCCSignatureVerifyingStub(),
					client: client,
					appConfiguration: appConfigurationProvider
				)
			)
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
		store.enfRiskCalculationResult = ENFRiskCalculationResult(
			riskLevel: .low,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: nil,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 0,
			calculationDate: lastExposureDetectionDate,
			riskLevelPerDate: [:],
			minimumDistinctEncountersWithHighRiskPerDate: [:]
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
		client.fetchPackageRequestFailure = Client.Failure.noResponse

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: downloadedPackagesStore,
			client: client,
			wifiClient: client,
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
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: cachedAppConfig,
				healthCertificateService: HealthCertificateService(
					store: store,
					signatureVerifying: DCCSignatureVerifyingStub(),
					client: client,
					appConfiguration: cachedAppConfig
				)
			)
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
		store.enfRiskCalculationResult = ENFRiskCalculationResult(
			riskLevel: .low,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: nil,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 0,
			calculationDate: lastExposureDetectionDate,
			riskLevelPerDate: [:],
			minimumDistinctEncountersWithHighRiskPerDate: [:]
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

		let client = ClientMock()
		client.availableDaysAndHours = DaysAndHours(days: ["2020-10-02", "2020-10-01", "2020-10-03", "2020-10-04"], hours: [1, 2])

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: downloadedPackagesStore,
			client: client,
			wifiClient: client,
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
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: cachedAppConfig,
				healthCertificateService: HealthCertificateService(
					store: store,
					signatureVerifying: DCCSignatureVerifyingStub(),
					client: client,
					appConfiguration: cachedAppConfig
				)
			)
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
		store.enfRiskCalculationResult = ENFRiskCalculationResult(
			riskLevel: .low,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: nil,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 0,
			calculationDate: lastExposureDetectionDate,
			riskLevelPerDate: [:],
			minimumDistinctEncountersWithHighRiskPerDate: [:]
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
		client.fetchPackageRequestFailure = Client.Failure.noResponse

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: downloadedPackagesStore,
			client: client,
			wifiClient: client,
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
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: cachedAppConfig,
				healthCertificateService: HealthCertificateService(
					store: store,
					signatureVerifying: DCCSignatureVerifyingStub(),
					client: client,
					appConfiguration: cachedAppConfig
				)
			)
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
		store.enfRiskCalculationResult = ENFRiskCalculationResult(
			riskLevel: .low,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: nil,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 0,
			calculationDate: lastExposureDetectionDate,
			riskLevelPerDate: [:],
			minimumDistinctEncountersWithHighRiskPerDate: [:]
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

		let client = ClientMock()
		client.availableDaysAndHours = DaysAndHours(days: ["2020-10-02", "2020-10-01", "2020-10-03", "2020-10-04"], hours: [1, 2])

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: downloadedPackagesStore,
			client: client,
			wifiClient: client,
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
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: cachedAppConfig,
				healthCertificateService: HealthCertificateService(
					store: store,
					signatureVerifying: DCCSignatureVerifyingStub(),
					client: client,
					appConfiguration: cachedAppConfig
				)
			)
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

private func makeRiskConfigHighFrequency() -> RiskProvidingConfiguration {
	let exposureChecksPerDay = 6
	let validityDuration = DateComponents(day: 1)
	return RiskProvidingConfiguration(
		exposureDetectionValidityDuration: validityDuration,
		exposureDetectionInterval: DateComponents(hour: 24 / exposureChecksPerDay),
		detectionMode: .automatic
	)
}

private func makeEnfRiskCalculationResultMock(withCalculationDate: Date) -> ENFRiskCalculationResult {
	return ENFRiskCalculationResult(
		riskLevel: .low,
		minimumDistinctEncountersWithLowRisk: 0,
		minimumDistinctEncountersWithHighRisk: 0,
		mostRecentDateWithLowRisk: nil,
		mostRecentDateWithHighRisk: nil,
		numberOfDaysWithLowRisk: 0,
		numberOfDaysWithHighRisk: 0,
		calculationDate: withCalculationDate,
		riskLevelPerDate: [:],
		minimumDistinctEncountersWithHighRiskPerDate: [:]
	)
}

private func makeCheckinRiskCalculationResult() -> CheckinRiskCalculationResult {
	return CheckinRiskCalculationResult(
		calculationDate: Date(),
		checkinIdsWithRiskPerDate: [:],
		riskLevelPerDate: [:]
	)
}

private func makeKeyPackageDownloadMock(with store: Store) -> KeyPackageDownload {
	let downloadedPackagesStore: DownloadedPackagesStore = DownloadedPackagesSQLLiteStore.inMemory()
	downloadedPackagesStore.open()

	let client = ClientMock(availableDaysAndHours: DaysAndHours(days: ["day"], hours: [0]))
	return KeyPackageDownload(
		downloadedPackagesStore: downloadedPackagesStore,
		client: client,
		wifiClient: client,
		store: store
	)
}

private func makeTraceWarningPackageDownloadMock(with store: Store, appConfig: AppConfigurationProviding) -> TraceWarningPackageDownload {
	let mockEventStore = MockEventStore()
	let client = ClientMock()
	return TraceWarningPackageDownload(
		client: client,
		store: store,
		eventStore: mockEventStore
	)
}

private func makeCoronaTestServiceMock(store: Store) -> CoronaTestService {
	let client = ClientMock()
	let appConfig = CachedAppConfigurationMock(with: SAP_Internal_V2_ApplicationConfigurationIOS())
	let healthCertificateService = HealthCertificateService(store: store, client: client, appConfiguration: appConfig)
	let eventStore = MockEventStore()
	let diaryStore = MockDiaryStore()
	return CoronaTestService(
		client: client,
		store: store,
		eventStore: eventStore,
		diaryStore: diaryStore,
		appConfiguration: appConfig,
		healthCertificateService: healthCertificateService
	)
}

private class ENFRiskCalculationFake: ENFRiskCalculationProtocol {
	
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

		return ENFRiskCalculationResult(
			riskLevel: riskLevel,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: nil,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 0,
			calculationDate: Date(),
			riskLevelPerDate: riskLevelPerDate,
			minimumDistinctEncountersWithHighRiskPerDate: [:]
		)
	}
	
	var mappedExposureWindows: [RiskCalculationExposureWindow] = []
}

private class CheckinRiskCalculationFake: CheckinRiskCalculationProtocol {

	init(
		riskLevelPerDate: [Date: RiskLevel] = [Date(): .low]
	) {
		self.riskLevelPerDate = riskLevelPerDate
	}

	let riskLevelPerDate: [Date: RiskLevel]

	func calculateRisk(with config: SAP_Internal_V2_ApplicationConfigurationIOS) -> CheckinRiskCalculationResult {
		return CheckinRiskCalculationResult(calculationDate: Date(), checkinIdsWithRiskPerDate: [Date: [CheckinIdWithRisk]](), riskLevelPerDate: riskLevelPerDate)
	}
}

final class ExposureDetectionDelegateStub: ExposureDetectionDelegate {

	private let result: Result<[ENExposureWindow], Error>
	private let keyPackagesToWrite: WrittenPackages

	var exposureWindowsWereDetected = false
	var numberOfDetectionCalls = 0

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
		numberOfDetectionCalls += 1
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

private class RiskProviderBuilder {
	var config: RiskProvidingConfiguration?
	var store: Store?
	var appConfig: AppConfigurationProviding?
	var exposureManagerState: ExposureManagerState?
	var enfRiskCalculation: ENFRiskCalculationProtocol?
	var checkinRiskCalculation: CheckinRiskCalculationProtocol?
	var keyPackageDownload: KeyPackageDownloadProtocol?
	var traceWarningPackageDownload: TraceWarningPackageDownloading?
	weak var exposureDetectionDelegate: ExposureDetectionDelegate?
	var coronaTestService: CoronaTestService?
	
	func configureRiskConfig(riskConfig: RiskProvidingConfiguration) {
		self.config = riskConfig
	}
	func configureStore(store: Store) {
		self.store = store
	}
	func configureAppConfig(appConfig: AppConfigurationProviding) {
		self.appConfig = appConfig
	}
	func configureExpManagerState(state: ExposureManagerState) {
		self.exposureManagerState = state
	}
	func configureEnfRiskCalc(riskCalc: ENFRiskCalculationProtocol) {
		self.enfRiskCalculation = riskCalc
	}
	func configureCheckinRiskCalc(riskCalc: CheckinRiskCalculationProtocol) {
		self.checkinRiskCalculation = riskCalc
	}
	func configureKeyDownload(download: KeyPackageDownloadProtocol) {
		self.keyPackageDownload = download
	}
	func configureTraceWarnDownload(download: TraceWarningPackageDownloading) {
		self.traceWarningPackageDownload = download
	}
	func configureExposureDetection(delegate: ExposureDetectionDelegate) {
		self.exposureDetectionDelegate = delegate
	}
	func configureCoronaTestService(service: CoronaTestService) {
		self.coronaTestService = service
	}
	
	func build() -> RiskProvider {
		let config = self.config ?? makeRiskConfigHighFrequency()
		let store: Store = self.store ?? MockTestStore()
		let appConfig = self.appConfig ??
			CachedAppConfigurationMock(with: SAP_Internal_V2_ApplicationConfigurationIOS())
		let exposureManagerState = self.exposureManagerState ??
			.init(authorized: true, enabled: true, status: .active)
		let enfRiskCalculation = self.enfRiskCalculation ?? ENFRiskCalculationFake()
		let checkinRiskCalculation = self.checkinRiskCalculation ?? CheckinRiskCalculationFake()
		let keyPackageDownload = self.keyPackageDownload ??
			makeKeyPackageDownloadMock(with: store)
		let traceWarningPackageDownload = self.traceWarningPackageDownload ??
			makeTraceWarningPackageDownloadMock(with: store, appConfig: appConfig)
		let exposureDetectionDelegate = self.exposureDetectionDelegate ??
			ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))
		let coronaTestService = self.coronaTestService ?? makeCoronaTestServiceMock(store: store)

		return RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: appConfig,
			exposureManagerState: exposureManagerState,
			enfRiskCalculation: enfRiskCalculation,
			checkinRiskCalculation: checkinRiskCalculation,
			keyPackageDownload: keyPackageDownload,
			traceWarningPackageDownload: traceWarningPackageDownload,
			exposureDetectionExecutor: exposureDetectionDelegate,
			coronaTestService: coronaTestService
		)
	}
}

struct DummyError: Error { }
