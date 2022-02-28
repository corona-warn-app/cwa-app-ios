//
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
import ZIPFoundation
@testable import ENA

class CCLServiceConfigurationTests: CCLServiceBaseTests {

	// MARK: - Configuration logic on CCLService Layer

	func testGIVEN_emptyCache_WHEN_404_THEN_didChangeIsFalse() throws {
		// GIVEN
		let eTag = "DummyDataETag"
		let appConfiguration = CachedAppConfigurationMock()
		let stack = MockNetworkStack(
			httpStatus: 404,
			headerFields: [
				"ETag": eTag
			]
		)
		
		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let cclService = CCLService(restServiceProvider, appConfiguration: appConfiguration, cclServiceMode: [.configuration], signatureVerifier: MockVerifier())
		let expectation = expectation(description: "update finished")

		// WHEN
		var result: Bool = false
		cclService.updateConfiguration { didChange in
			result = didChange
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertFalse(result)
	}

	func testGIVEN_cachedCCLConfigurationFromYesterDay_WHEN_200_THEN_didChangeIsTrue() throws {
		// GIVEN
		let eTag = "DummyDataETag"
		let cclConfigurationData = try cclConfigurationData()
		let appConfiguration = CachedAppConfigurationMock()

		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: [
				"ETag": eTag + "new"
			],
			responseData: cclConfigurationData
		)
		let cache = try cache(with: Locator.CCLConfiguration(isFake: false), eTag: eTag, date: yesterday, responseData: cclConfigurationData)
		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: cache)
		let cclService = CCLService(restServiceProvider, appConfiguration: appConfiguration, cclServiceMode: [.configuration], signatureVerifier: MockVerifier())
		let expectation = expectation(description: "update finished")

		// WHEN
		var result: Bool = false
		cclService.updateConfiguration { didChange in
			result = didChange
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertTrue(result)
	}

	func testGIVEN_cachedCCLConfigurationFromToday_WHEN_200_THEN_didChangeIsFalse() throws {
		// GIVEN
		let eTag = "DummyDataETag"
		let cclConfigurationData = try cclConfigurationData()
		let appConfiguration = CachedAppConfigurationMock()

		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: [
				"ETag": eTag + "new"
			],
			responseData: cclConfigurationData
		)
		let cache = try cache(with: Locator.CCLConfiguration(isFake: false), eTag: eTag, date: today, responseData: cclConfigurationData)
		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: cache)
		let cclService = CCLService(restServiceProvider, appConfiguration: appConfiguration, cclServiceMode: [.configuration], signatureVerifier: MockVerifier())
		let expectation = expectation(description: "update finished")

		// WHEN
		var result: Bool = false
		cclService.updateConfiguration { didChange in
			result = didChange
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertFalse(result)
	}

	// MARK: - Configuration version

	func testGIVEN_defaultCCLConfiguration_WHEN_gettingVersion_THEN_versionIsNotEmpty() throws {
		// WHEN
		let defaultConfigurationVersions = try defaultConfigurationVersions()

		// THEN
		XCTAssertFalse(defaultConfigurationVersions.isEmpty)
		XCTAssertFalse(try XCTUnwrap(defaultConfigurationVersions.first).isEmpty)
	}

	func testGIVEN_cachedCCLConfigurationWithOnlyDefaultVersion_WHEN_gettingVersion_THEN_versionIsCorrect() throws {
		// GIVEN
		let appConfiguration = CachedAppConfigurationMock()

		let cache = try cache()
		let restServiceProvider = RestServiceProvider(session: MockNetworkStack().urlSession, cache: cache)
		let cclService = CCLService(restServiceProvider, appConfiguration: appConfiguration, cclServiceMode: [.configuration], signatureVerifier: MockVerifier())

		// WHEN
		let version = cclService.configurationVersion

		// THEN
		XCTAssertEqual(version, (try defaultConfigurationVersionsString()))
	}

	func testGIVEN_cachedCCLConfigurationsSameAsDefaultVersions_WHEN_gettingVersion_THEN_versionIsCorrect() throws {
		// GIVEN
		let eTag = "DummyDataETag"
		let cclConfigurationData = try XCTUnwrap(
			Archive.createArchiveData(
				accessMode: .create,
				cborData: HealthCertificateToolkit.CCLConfigurationCBORDataFake(configs: try defaultConfigurations())
			)
		)
		let appConfiguration = CachedAppConfigurationMock()

		let cache = try cache(with: Locator.CCLConfiguration(isFake: false), eTag: eTag, date: today, responseData: cclConfigurationData)
		let restServiceProvider = RestServiceProvider(session: MockNetworkStack().urlSession, cache: cache)
		let cclService = CCLService(restServiceProvider, appConfiguration: appConfiguration, cclServiceMode: [.configuration], signatureVerifier: MockVerifier())

		// WHEN
		let version = cclService.configurationVersion

		// THEN
		XCTAssertEqual(version, (try defaultConfigurationVersionsString()))
	}

	func testGIVEN_cachedCCLConfigurationWithOneVersion_WHEN_gettingVersion_THEN_versionIsCorrect() throws {
		// GIVEN
		let eTag = "DummyDataETag"
		let cclConfigurationData = try cclConfigurationData(
			identifiersAndVersions: [
				"AAA-Cached-CCL": "Cached-Version"
			]
		)
		let appConfiguration = CachedAppConfigurationMock()

		let cache = try cache(with: Locator.CCLConfiguration(isFake: false), eTag: eTag, date: today, responseData: cclConfigurationData)
		let restServiceProvider = RestServiceProvider(session: MockNetworkStack().urlSession, cache: cache)
		let cclService = CCLService(restServiceProvider, appConfiguration: appConfiguration, cclServiceMode: [.configuration], signatureVerifier: MockVerifier())

		// WHEN
		let version = cclService.configurationVersion

		// THEN
		XCTAssertEqual(version, "Cached-Version, " + (try defaultConfigurationVersionsString()))
	}

	func testGIVEN_cachedCCLConfigurationWithMultipleVersions_WHEN_gettingVersion_THEN_versionIsCorrect() throws {
		// GIVEN
		let eTag = "DummyDataETag"
		let cclConfigurationData = try cclConfigurationData(
			identifiersAndVersions: [
				"AAA-Cached-CCL-0002": "1.0.1",
				"AAA-Cached-CCL-0004": "1.2.5",
				"AAA-Cached-CCL-0014": "1.0.37",
				"AAA-Cached-CCL-0001": "1.0.0"
			]
		)
		let appConfiguration = CachedAppConfigurationMock()

		let cache = try cache(with: Locator.CCLConfiguration(isFake: false), eTag: eTag, date: today, responseData: cclConfigurationData)
		let restServiceProvider = RestServiceProvider(session: MockNetworkStack().urlSession, cache: cache)
		let cclService = CCLService(restServiceProvider, appConfiguration: appConfiguration, cclServiceMode: [.configuration], signatureVerifier: MockVerifier())

		// WHEN
		let version = cclService.configurationVersion

		// THEN
		XCTAssertEqual(version, "1.0.0, 1.0.1, 1.2.5, 1.0.37, " + (try defaultConfigurationVersionsString()))
	}

	func testGIVEN_newCCLConfiguration_WHEN_updatingConfiguration_THEN_versionIsUpdated() throws {
		// GIVEN
		let eTag = "DummyDataETag"
		let appConfiguration = CachedAppConfigurationMock()
		let oldCCLConfigurationData = try cclConfigurationData(
			identifiersAndVersions: [
				"AAA-Cached-CCL-0001": "1.0.0"
			]
		)

		let updatedCCLConfigurationData = try cclConfigurationData(
			identifiersAndVersions: [
				"AAA-Cached-CCL-0003": "1.0.2",
				"AAA-Cached-CCL-0005": "1.1.0"
			]
		)

		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: [
				"ETag": eTag + "new"
			],
			responseData: updatedCCLConfigurationData
		)
		let cache = try cache(with: Locator.CCLConfiguration(isFake: false), eTag: eTag, date: yesterday, responseData: oldCCLConfigurationData)
		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: cache)
		let cclService = CCLService(restServiceProvider, appConfiguration: appConfiguration, cclServiceMode: [.configuration], signatureVerifier: MockVerifier())
		let expectation = expectation(description: "update finished")

		// WHEN
		cclService.updateConfiguration { _ in
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .short)

		XCTAssertEqual(cclService.configurationVersion, "1.0.2, 1.1.0, " + (try defaultConfigurationVersionsString()))
	}

	// MARK: - Helpers

	private func cclConfigurationData() throws -> Data {
		try XCTUnwrap(
			Archive.createArchiveData(
				accessMode: .create,
				cborData: HealthCertificateToolkit.CCLConfigurationCBORDataFake()
			)
		)
	}

	private func cclConfigurationData(identifiersAndVersions: [String: String]) throws -> Data {
		let configs = identifiersAndVersions
			.map { key, value in
				CCLConfiguration.fake(identifier: key, version: value)
			}

		return try XCTUnwrap(
			Archive.createArchiveData(
				accessMode: .create,
				cborData: HealthCertificateToolkit.CCLConfigurationCBORDataFake(configs: configs)
			)
		)
	}

	private func defaultConfigurations() throws -> [CCLConfiguration] {
		try XCTUnwrap(CCLConfigurationResource().defaultModel?.cclConfigurations)
	}

	private func defaultConfigurationVersions() throws -> [String] {
		try defaultConfigurations()
			.map { $0.version }
	}

	private func defaultConfigurationVersionsString() throws -> String {
		try defaultConfigurations()
			.map { $0.version }
			.joined(separator: ", ")
	}

	private func defaultConfigurationVersionIdentifiers() throws -> [String] {
		try defaultConfigurations()
			.map { $0.identifier }
	}

}
