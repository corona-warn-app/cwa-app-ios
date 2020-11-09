//
// Corona-Warn-App
//
// SAP SE and all other contributors /
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import XCTest
import ExposureNotification
@testable import ENA

private final class Summary: ENExposureDetectionSummary {}

// swiftlint:disable:next type_body_length
final class RiskProviderTests: XCTestCase {

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
		store.summary = SummaryMetadata(
			summary: CodableExposureDetectionSummary(
				daysSinceLastExposure: 0,
				matchedKeyCount: 0,
				maximumRiskScore: 0,
				attenuationDurations: [],
				maximumRiskScoreFullRange: 0
			),
			date: lastExposureDetectionDate
		)
		store.tracingStatusHistory = [.init(on: true, date: Date().addingTimeInterval(.init(days: -1)))]

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration,
			detectionMode: .automatic
		)

		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success(ENExposureDetectionSummary()))

		let downloadedPackagesStore: DownloadedPackagesStore = DownloadedPackagesSQLLiteStoreV1 .inMemory()
		downloadedPackagesStore.open()
		let client = ClientMock()
		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: downloadedPackagesStore,
			client: client,
			wifiClient: client,
			store: store
		)

		var appConfig = SAP_Internal_ApplicationConfiguration()
		var parameters = SAP_Internal_ExposureDetectionParametersIOS()
		parameters.maxExposureDetectionsPerInterval = 1
		appConfig.iosExposureDetectionParameters = parameters

		let appConfigurationMock = CachedAppConfigurationMock(appConfigurationResult: .success(appConfig))

		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: appConfigurationMock,
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			riskCalculation: RiskCalculationFake(),
			keyPackageDownload: keyPackageDownload,
			exposureDetectionExecutor: exposureDetectionDelegateStub
		)

		let requestRiskExpectation = expectation(description: "")
		riskProvider.requestRisk(userInitiated: false) { result in
			switch result {
			case .success:
				XCTAssertTrue(exposureDetectionDelegateStub.exposureDetectionWasExecuted)
				requestRiskExpectation.fulfill()
			case .failure:
				XCTFail("Failure is not expected 1.")
			}
		}

		waitForExpectations(timeout: 1.0)
	}

	func testExposureDetectionIsNotExecutedIfTracingHasNotBeenEnabledLongEnough() throws {
		let duration = DateComponents(day: 1)

		let calendar = Calendar.current

		let lastExposureDetectionDate = try XCTUnwrap(calendar.date(
			byAdding: .day,
			value: -3,
			to: Date(),
			wrappingComponents: false
		))

		let store = MockTestStore()
		store.summary = SummaryMetadata(
			summary: CodableExposureDetectionSummary(
				daysSinceLastExposure: 0,
				matchedKeyCount: 0,
				maximumRiskScore: 0,
				attenuationDurations: [],
				maximumRiskScoreFullRange: 0
			),
			date: lastExposureDetectionDate
		)
		// Tracing was only active for one hour, there is not enough data to calculate risk,
		// and we might get a rate limit error (ex. user reinstalls the app - losing tracing history - and risk is requested again)
		store.tracingStatusHistory = [.init(on: true, date: Date().addingTimeInterval(.init(hours: -1)))]

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration,
			detectionMode: .automatic
		)

		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success(ENExposureDetectionSummary()))

		let downloadedPackagesStore: DownloadedPackagesStore = DownloadedPackagesSQLLiteStoreV1 .inMemory()
		downloadedPackagesStore.open()
		let client = ClientMock()
		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: downloadedPackagesStore,
			client: client,
			wifiClient: client,
			store: store
		)

		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: CachedAppConfigurationMock(),
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			riskCalculation: RiskCalculationFake(),
			keyPackageDownload: keyPackageDownload,
			exposureDetectionExecutor: exposureDetectionDelegateStub
		)

		let expectThatRiskIsReturned = expectation(description: "expectThatRiskIsReturned")
		riskProvider.requestRisk(userInitiated: false) { result in

			switch result {
			case .success(let risk):
				expectThatRiskIsReturned.fulfill()
				XCTAssertEqual(risk.level, .unknownInitial, "Tracing was active for < 24 hours but risk is not .unknownInitial")
				XCTAssertFalse(exposureDetectionDelegateStub.exposureDetectionWasExecuted)
			case .failure:
				XCTFail("Failure not expected.")
			}
		}
		waitForExpectations(timeout: 1.0)
	}

	func testThatDetectionIsRequested() throws {
		let duration = DateComponents(day: 1)

		let store = MockTestStore()
		store.summary = nil
		store.tracingStatusHistory = [.init(on: true, date: Date().addingTimeInterval(.init(days: -1)))]

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration
		)

		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success(ENExposureDetectionSummary()))

		let sapAppConfig = SAP_Internal_ApplicationConfiguration.with {
			$0.exposureConfig = SAP_Internal_RiskScoreParameters()
		}
		let cachedAppConfig = CachedAppConfigurationMock(appConfigurationResult: .success(sapAppConfig))

		let downloadedPackagesStore: DownloadedPackagesStore = DownloadedPackagesSQLLiteStoreV1 .inMemory()
		downloadedPackagesStore.open()
		let client = ClientMock()
		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: downloadedPackagesStore,
			client: client,
			wifiClient: client,
			store: store
		)

		let riskProvider = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: cachedAppConfig,
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			riskCalculation: RiskCalculationFake(),
			keyPackageDownload: keyPackageDownload,
			exposureDetectionExecutor: exposureDetectionDelegateStub
		)

		let consumer = RiskConsumer()

		let didCalculateRiskCalled = expectation(description: "expect didCalculateRisk to be called")
		consumer.didCalculateRisk = { _ in
			didCalculateRiskCalled.fulfill()
		}
		consumer.didFailCalculateRisk = { _ in
			XCTFail("didFailCalculateRisk should not be called.")
		}

		riskProvider.observeRisk(consumer)
		riskProvider.requestRisk(userInitiated: true)

		waitForExpectations(timeout: 1.0)
	}

	func testThatDetectionFails() throws {
		let duration = DateComponents(day: 1)

		let store = MockTestStore()
		store.summary = nil
		store.tracingStatusHistory = [.init(on: true, date: Date().addingTimeInterval(.init(days: -1)))]

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration
		)

		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .failure(DummyError()))

		let sapAppConfig = SAP_Internal_ApplicationConfiguration.with {
			$0.exposureConfig = SAP_Internal_RiskScoreParameters()
		}
		let cachedAppConfig = CachedAppConfigurationMock(appConfigurationResult: .success(sapAppConfig))

		let downloadedPackagesStore: DownloadedPackagesStore = DownloadedPackagesSQLLiteStoreV1 .inMemory()
		downloadedPackagesStore.open()
		let client = ClientMock()
		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: downloadedPackagesStore,
			client: client,
			wifiClient: client,
			store: store
		)

		let sut = RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: cachedAppConfig,
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			riskCalculation: RiskCalculationFake(),
			keyPackageDownload: keyPackageDownload,
			exposureDetectionExecutor: exposureDetectionDelegateStub
		)

		let consumer = RiskConsumer()
		let didCalculateRiskFailedCalled = expectation(
			description: "expect didCalculateFailedRisk to be called"
		)

		consumer.didCalculateRisk = { _ in
			XCTFail("didCalculateRisk should not be called.")
		}

		consumer.didFailCalculateRisk = { _ in
			didCalculateRiskFailedCalled.fulfill()
		}

		sut.observeRisk(consumer)
		sut.requestRisk(userInitiated: true)
		
		waitForExpectations(timeout: 1.0)
	}

	func testShouldShowRiskStatusLoweredAlertIntitiallyFalseIsSetToTrueWhenRiskStatusLowers() throws {
		let store = MockTestStore()
		store.shouldShowRiskStatusLoweredAlert = false

		let riskProvider = try riskProviderChangingRiskLevel(from: .increased, to: .low, store: store)

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

		let riskProvider = try riskProviderChangingRiskLevel(from: .increased, to: .low, store: store)

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

		let riskProvider = try riskProviderChangingRiskLevel(from: .low, to: .increased, store: store)

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

		let riskProvider = try riskProviderChangingRiskLevel(from: .low, to: .increased, store: store)

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

	func testShouldShowRiskStatusLoweredAlertInitiallyTrueKeepsValueWhenRiskStatusStaysIncreased() throws {
		let store = MockTestStore()
		store.shouldShowRiskStatusLoweredAlert = true

		let riskProvider = try riskProviderChangingRiskLevel(from: .increased, to: .increased, store: store)

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

	func testShouldShowRiskStatusLoweredAlertInitiallyFalseKeepsValueWhenRiskStatusStaysIncrease() throws {
		let store = MockTestStore()
		store.shouldShowRiskStatusLoweredAlert = false

		let riskProvider = try riskProviderChangingRiskLevel(from: .increased, to: .increased, store: store)

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

	// MARK: - Private

	private func riskProviderChangingRiskLevel(from previousRiskLevel: EitherLowOrIncreasedRiskLevel, to newRiskLevel: EitherLowOrIncreasedRiskLevel, store: MockTestStore) throws -> RiskProvider {
		let duration = DateComponents(day: 2)

		store.tracingStatusHistory = [.init(on: true, date: Date().addingTimeInterval(.init(days: -1)))]
		store.previousRiskLevel = previousRiskLevel

		let lastExposureDetectionDate = try XCTUnwrap(
			Calendar.current.date(byAdding: .day, value: -1, to: Date(), wrappingComponents: false)
		)

		store.summary = SummaryMetadata(
			summary: .summary(for: newRiskLevel),
			date: lastExposureDetectionDate
		)

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration,
			detectionMode: .manual
		)

		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success(ENExposureDetectionSummary()))

		let appConfigurationProvider = CachedAppConfigurationMock(appConfigurationResult: .success(.riskCalculationAppConfig))

		let downloadedPackagesStore: DownloadedPackagesStore = DownloadedPackagesSQLLiteStoreV1 .inMemory()
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
			keyPackageDownload: keyPackageDownload,
			exposureDetectionExecutor: exposureDetectionDelegateStub
		)
	}

}

struct RiskCalculationFake: RiskCalculationProtocol {
	func risk(
		summary: CodableExposureDetectionSummary?,
		configuration: SAP_Internal_ApplicationConfiguration,
		dateLastExposureDetection: Date?,
		activeTracing: ActiveTracing,
		preconditions: ExposureManagerState,
		previousRiskLevel: EitherLowOrIncreasedRiskLevel?,
		providerConfiguration: RiskProvidingConfiguration
	) -> Risk? {
		let fakeRisk = Risk(
			level: .low,
			details: Risk.Details(
				numberOfExposures: 0,
				activeTracing: .init(interval: 336 * 3600),  // two weeks
				exposureDetectionDate: Date()),
			riskLevelHasChanged: true
		)
		return fakeRisk
	}
}

final class ExposureDetectionDelegateStub: ExposureDetectionDelegate {

	private let result: Result<ENExposureDetectionSummary, Error>
	private let keyPackagesToWrite: WrittenPackages

	var exposureDetectionWasExecuted = false

	init(
		result: Result<ENExposureDetectionSummary, Error>,
		keyPackagesToWrite: WrittenPackages = ExposureDetectionDelegateStub.defaultKeyPackages) {
		self.result = result
		self.keyPackagesToWrite = keyPackagesToWrite
	}

	func exposureDetectionWriteDownloadedPackages(country: Country.ID) -> WrittenPackages? {
		return keyPackagesToWrite
	}

	func exposureDetection(_ detection: ExposureDetection, detectSummaryWithConfiguration configuration: ENExposureConfiguration, writtenPackages: WrittenPackages, completion: @escaping DetectionHandler) -> Progress {
		exposureDetectionWasExecuted = true
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
