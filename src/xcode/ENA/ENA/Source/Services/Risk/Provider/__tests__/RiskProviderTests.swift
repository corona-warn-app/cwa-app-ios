//
// 🦠 Corona-Warn-App
//

import XCTest
import ExposureNotification
@testable import ENA

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
final class RiskProviderTests: XCTestCase {

	func testGIVEN_RiskProvider_WHEN_requestRisk_THEN_TimeoutWillTrigger() {
		// GIVEN
		let duration = DateComponents(day: 1)

		let store = MockTestStore()
		store.riskCalculationResult = nil

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration
		)

		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))

		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: CachedAppConfigurationMock(with: SAP_Internal_V2_ApplicationConfigurationIOS()),
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			riskCalculation: RiskCalculationFake(),
			keyPackageDownload: makeKeyPackageDownloadMock(with: store),
			exposureDetectionExecutor: exposureDetectionDelegateStub
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

		let store = MockTestStore()
		store.riskCalculationResult = nil

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration
		)

		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))

		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: CachedAppConfigurationMock(with: SAP_Internal_V2_ApplicationConfigurationIOS()),
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			riskCalculation: RiskCalculationFake(),
			keyPackageDownload: makeKeyPackageDownloadMock(with: store),
			exposureDetectionExecutor: exposureDetectionDelegateStub
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
		store.riskCalculationResult = RiskCalculationResult(
			riskLevel: .low,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: nil,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 0,
			calculationDate: lastExposureDetectionDate
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

		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: CachedAppConfigurationMock(with: SAP_Internal_V2_ApplicationConfigurationIOS()),
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			riskCalculation: RiskCalculationFake(),
			keyPackageDownload: makeKeyPackageDownloadMock(with: store),
			exposureDetectionExecutor: exposureDetectionDelegateStub
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
		store.riskCalculationResult = nil
		store.positiveTestResultWasShown = false
		store.lastSuccessfulSubmitDiagnosisKeyTimestamp = nil

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration
		)

		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))

		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: CachedAppConfigurationMock(with: SAP_Internal_V2_ApplicationConfigurationIOS()),
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			riskCalculation: RiskCalculationFake(),
			keyPackageDownload: makeKeyPackageDownloadMock(with: store),
			exposureDetectionExecutor: exposureDetectionDelegateStub
		)

		let consumer = RiskConsumer()

		let didCalculateRiskExpectation = expectation(description: "expect didCalculateRisk to be called")

		let didFailCalculateRiskExpectation = expectation(description: "expect didFailCalculateRisk not to be called")
		didFailCalculateRiskExpectation.isInverted = true

		let didChangeActivityStateExpectation = expectation(description: "expect didChangeActivityState to be called 3 times")
		didChangeActivityStateExpectation.expectedFulfillmentCount = 3

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
		store.riskCalculationResult = nil
		store.positiveTestResultWasShown = false
		store.lastSuccessfulSubmitDiagnosisKeyTimestamp = nil

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration
		)

		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .failure(DummyError()))

		let sut = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: CachedAppConfigurationMock(with: SAP_Internal_V2_ApplicationConfigurationIOS()),
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			riskCalculation: RiskCalculationFake(),
			keyPackageDownload: makeKeyPackageDownloadMock(with: store),
			exposureDetectionExecutor: exposureDetectionDelegateStub
		)

		let consumer = RiskConsumer()

		let didCalculateRiskExpectation = expectation(description: "expect didCalculateRisk to be called")
		didCalculateRiskExpectation.isInverted = true

		let didFailCalculateRiskExpectation = expectation(description: "expect didFailCalculateRisk not to be called")

		let didChangeActivityStateExpectation = expectation(description: "expect didChangeActivityState to be called 3 times")
		didChangeActivityStateExpectation.expectedFulfillmentCount = 3

		consumer.didCalculateRisk = { _ in
			didCalculateRiskExpectation.fulfill()
		}
		consumer.didFailCalculateRisk = { _ in
			didFailCalculateRiskExpectation.fulfill()
		}
		consumer.didChangeActivityState = { _ in
			didChangeActivityStateExpectation.fulfill()
		}

		sut.observeRisk(consumer)
		sut.requestRisk(userInitiated: true)
		
		waitForExpectations(timeout: .medium)
	}

	func testThatDetectionIsNotRequestedIfPositiveTestResultWasShown() throws {
		let duration = DateComponents(day: 1)

		let store = MockTestStore()
		store.riskCalculationResult = nil
		store.positiveTestResultWasShown = true

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration
		)

		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))

		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: CachedAppConfigurationMock(with: SAP_Internal_V2_ApplicationConfigurationIOS()),
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			riskCalculation: RiskCalculationFake(),
			keyPackageDownload: makeKeyPackageDownloadMock(with: store),
			exposureDetectionExecutor: exposureDetectionDelegateStub
		)

		let consumer = RiskConsumer()

		let didCalculateRiskExpectation = expectation(description: "expect didCalculateRisk not to be called")
		didCalculateRiskExpectation.isInverted = true

		let didFailCalculateRiskExpectation = expectation(description: "expect didFailCalculateRisk not to be called")
		didFailCalculateRiskExpectation.isInverted = true

		let didChangeActivityStateExpectation = expectation(description: "expect didChangeActivityState not to be called")
		didChangeActivityStateExpectation.isInverted = true

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

	func testThatDetectionIsNotRequestedIfKeysWereSubmitted() throws {
		let duration = DateComponents(day: 1)

		let store = MockTestStore()
		store.riskCalculationResult = nil
		store.lastSuccessfulSubmitDiagnosisKeyTimestamp = Int64(Date().timeIntervalSince1970)

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration
		)

		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))

		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: CachedAppConfigurationMock(with: SAP_Internal_V2_ApplicationConfigurationIOS()),
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			riskCalculation: RiskCalculationFake(),
			keyPackageDownload: makeKeyPackageDownloadMock(with: store),
			exposureDetectionExecutor: exposureDetectionDelegateStub
		)

		let consumer = RiskConsumer()

		let didCalculateRiskExpectation = expectation(description: "expect didCalculateRisk not to be called")
		didCalculateRiskExpectation.isInverted = true

		let didFailCalculateRiskExpectation = expectation(description: "expect didFailCalculateRisk not to be called")
		didFailCalculateRiskExpectation.isInverted = true

		let didChangeActivityStateExpectation = expectation(description: "expect didChangeActivityState not to be called")
		didChangeActivityStateExpectation.isInverted = true

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
			appDelegate.executeENABackgroundTask { _ in }
		}

		waitForExpectations(timeout: .extraLong)
	}


	// MARK: - Private

	private func makeSomeRiskProvider() -> RiskProvider {
		let duration = DateComponents(day: 1)

		let store = MockTestStore()
		store.riskCalculationResult = nil

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration
		)

		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))

		let downloadedPackagesStore: DownloadedPackagesStore = DownloadedPackagesSQLLiteStore.inMemory()
		downloadedPackagesStore.open()

		return RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: CachedAppConfigurationMock(with: SAP_Internal_V2_ApplicationConfigurationIOS()),
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			riskCalculation: RiskCalculationFake(),
			keyPackageDownload: makeKeyPackageDownloadMock(with: store),
			exposureDetectionExecutor: exposureDetectionDelegateStub
		)

	}

	private func makeKeyPackageDownloadMock(with store: Store) -> KeyPackageDownload {
		let downloadedPackagesStore: DownloadedPackagesStore = DownloadedPackagesSQLLiteStore.inMemory()
		downloadedPackagesStore.open()

		let client = ClientMock()
		return KeyPackageDownload(
			downloadedPackagesStore: downloadedPackagesStore,
			client: client,
			wifiClient: client,
			store: store
		)
	}

	private func riskProviderChangingRiskLevel(from previousRiskLevel: RiskLevel, to newRiskLevel: RiskLevel, store: MockTestStore) throws -> RiskProvider {
		let duration = DateComponents(day: 2)

		let lastExposureDetectionDate = try XCTUnwrap(
			Calendar.current.date(byAdding: .day, value: -1, to: Date(), wrappingComponents: false)
		)

		store.riskCalculationResult = RiskCalculationResult(
			riskLevel: previousRiskLevel,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: nil,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 0,
			calculationDate: lastExposureDetectionDate
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
		return RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: appConfigurationProvider,
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			riskCalculation: RiskCalculationFake(riskLevel: newRiskLevel),
			keyPackageDownload: keyPackageDownload,
			exposureDetectionExecutor: exposureDetectionDelegateStub
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
		store.riskCalculationResult = RiskCalculationResult(
			riskLevel: .low,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: nil,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 0,
			calculationDate: lastExposureDetectionDate
		)
		store.tracingStatusHistory = [.init(on: true, date: Date().addingTimeInterval(.init(days: -1)))]
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

		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: CachedAppConfigurationMock(with: appConfig),
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			riskCalculation: RiskCalculationFake(),
			keyPackageDownload: keyPackageDownload,
			exposureDetectionExecutor: exposureDetectionDelegateStub
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
		store.riskCalculationResult = RiskCalculationResult(
			riskLevel: .low,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: nil,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 0,
			calculationDate: lastExposureDetectionDate
		)
		store.tracingStatusHistory = [.init(on: true, date: Date().addingTimeInterval(.init(days: -1)))]

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

		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: CachedAppConfigurationMock(with: appConfig),
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			riskCalculation: RiskCalculationFake(),
			keyPackageDownload: keyPackageDownload,
			exposureDetectionExecutor: exposureDetectionDelegateStub
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
		store.riskCalculationResult = RiskCalculationResult(
			riskLevel: .low,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: nil,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 0,
			calculationDate: lastExposureDetectionDate
		)
		store.tracingStatusHistory = [.init(on: true, date: Date().addingTimeInterval(.init(days: -1)))]
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

		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: CachedAppConfigurationMock(with: appConfig),
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			riskCalculation: RiskCalculationFake(),
			keyPackageDownload: keyPackageDownload,
			exposureDetectionExecutor: exposureDetectionDelegateStub
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
		store.riskCalculationResult = RiskCalculationResult(
			riskLevel: .low,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: nil,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 0,
			calculationDate: lastExposureDetectionDate
		)
		store.tracingStatusHistory = [.init(on: true, date: Date().addingTimeInterval(.init(days: -1)))]

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

		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: CachedAppConfigurationMock(with: appConfig),
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			riskCalculation: RiskCalculationFake(),
			keyPackageDownload: keyPackageDownload,
			exposureDetectionExecutor: exposureDetectionDelegateStub
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

}

private struct RiskCalculationFake: RiskCalculationProtocol {

	init(riskLevel: RiskLevel = .low) {
		self.riskLevel = riskLevel
	}

	let riskLevel: RiskLevel

	func calculateRisk(
		exposureWindows: [ExposureWindow],
		configuration: RiskCalculationConfiguration
	) throws -> RiskCalculationResult {
		RiskCalculationResult(
			riskLevel: riskLevel,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: nil,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 0,
			calculationDate: Date()
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
