//
// Corona-Warn-App
//
// SAP SE and all other contributors
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

class RiskProviderAndNewKeyPackagesTests: XCTestCase {

	func test_When_didNotDownloadNewPackages_And_LastDetectionIsLessThen24HoursAgo_Then_NoDetectionIsExecuted() throws {

		let calendar = Calendar.current

		let lastExposureDetectionDate = try XCTUnwrap(calendar.date(
			byAdding: .hour,
			value: -12,
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
		store.lastKeyPackageDownloadDate = .distantPast

		let exposureDetectionsInterval = 6
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: DateComponents(day: 1),
			exposureDetectionInterval: DateComponents(hour: 24 / exposureDetectionsInterval),
			detectionMode: .automatic
		)

		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success(ENExposureDetectionSummary()))

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
		var parameters = SAP_Internal_ExposureDetectionParametersIOS()
		parameters.maxExposureDetectionsPerInterval = 6
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
				XCTAssertFalse(exposureDetectionDelegateStub.exposureDetectionWasExecuted)
				requestRiskExpectation.fulfill()
			case .failure:
				XCTFail("Failure is not expected 1.")
			}
		}

		waitForExpectations(timeout: 1.0)
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

		let exposureDetectionsInterval = 6
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: DateComponents(day: 1),
			exposureDetectionInterval: DateComponents(hour: 24 / exposureDetectionsInterval),
			detectionMode: .automatic
		)

		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success(ENExposureDetectionSummary()))

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
		var parameters = SAP_Internal_ExposureDetectionParametersIOS()
		parameters.maxExposureDetectionsPerInterval = 6
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

	func test_When_didNotDownloadNewPackages_And_LastDetectionIsMoreThen24HoursAgo_Then_DetectionIsExecuted() throws {

		let calendar = Calendar.current

		let lastExposureDetectionDate = try XCTUnwrap(calendar.date(
			byAdding: .hour,
			value: -25,
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
		store.lastKeyPackageDownloadDate = .distantPast

		let exposureDetectionsInterval = 6
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: DateComponents(day: 1),
			exposureDetectionInterval: DateComponents(hour: 24 / exposureDetectionsInterval),
			detectionMode: .automatic
		)

		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success(ENExposureDetectionSummary()))

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
		var parameters = SAP_Internal_ExposureDetectionParametersIOS()
		parameters.maxExposureDetectionsPerInterval = 6
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

	func test_When_didDownloadNewPackages_And_LastDetectionIsMoreThen24HoursAgo_Then_DetectionIsExecuted() throws {

		let calendar = Calendar.current

		let lastExposureDetectionDate = try XCTUnwrap(calendar.date(
			byAdding: .hour,
			value: -25,
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

		let exposureDetectionsInterval = 6
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: DateComponents(day: 1),
			exposureDetectionInterval: DateComponents(hour: 24 / exposureDetectionsInterval),
			detectionMode: .automatic
		)

		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success(ENExposureDetectionSummary()))

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
		var parameters = SAP_Internal_ExposureDetectionParametersIOS()
		parameters.maxExposureDetectionsPerInterval = 6
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
}
