//
// 🦠 Corona-Warn-App
//

import XCTest
import ExposureNotification
import HealthCertificateToolkit
@testable import ENA

final class RiskProviderError13Tests: CWATestCase {
	
	func testThatDetectionFails_Error13_lastExposureDateIsTooOld() throws {
		let duration = DateComponents(day: 1)
		let lastExposureDetectionDate = try XCTUnwrap(Calendar.current.date(
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
			calculationDate: lastExposureDetectionDate,
			checkinIdsWithRiskPerDate: [:],
			riskLevelPerDate: [:]
		)

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration,
			detectionMode: .automatic
		)

		let error = ENError(.rateLimited)

		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .failure(error))
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

	func testThatDetectionFails_SkippedError13() throws {
		let duration = DateComponents(day: 1)
		let lastExposureDetectionDate = try XCTUnwrap(Calendar.current.date(
			byAdding: .day,
			value: -1,
			to: Date(),
			wrappingComponents: false
		))

		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake(
			calculationDate: lastExposureDetectionDate
		)
		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(
			calculationDate: lastExposureDetectionDate,
			checkinIdsWithRiskPerDate: [:],
			riskLevelPerDate: [:]
		)

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration,
			detectionMode: .automatic
		)

		let error = ENError(.rateLimited)

		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .failure(error))
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

		let didFailCalculateRiskExpectation = expectation(description: "expect didFailCalculateRisk not to be called")
		didFailCalculateRiskExpectation.isInverted = true

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


	func testThatDetectionFails_Error16_lastExposureDateIsTooOld() throws {
		let duration = DateComponents(day: 1)
		let lastExposureDetectionDate = try XCTUnwrap(Calendar.current.date(
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
			calculationDate: lastExposureDetectionDate,
			checkinIdsWithRiskPerDate: [:],
			riskLevelPerDate: [:]
		)

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration,
			detectionMode: .automatic
		)

		let error = ENError(.dataInaccessible)

		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .failure(error))
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

	func testThatDetectionFails_SkippedError16() throws {
		let duration = DateComponents(day: 1)
		let lastExposureDetectionDate = try XCTUnwrap(Calendar.current.date(
			byAdding: .day,
			value: -1,
			to: Date(),
			wrappingComponents: false
		))

		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake(
			calculationDate: lastExposureDetectionDate
		)
		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(
			calculationDate: lastExposureDetectionDate,
			checkinIdsWithRiskPerDate: [:],
			riskLevelPerDate: [:]
		)

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration,
			detectionMode: .automatic
		)

		let error = ENError(.dataInaccessible)

		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .failure(error))
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

		let didFailCalculateRiskExpectation = expectation(description: "expect didFailCalculateRisk not to be called")
		didFailCalculateRiskExpectation.isInverted = true

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

}
