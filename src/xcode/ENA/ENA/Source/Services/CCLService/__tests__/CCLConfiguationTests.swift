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
		let stack = MockNetworkStack(
			httpStatus: 404,
			headerFields: [
				"ETag": eTag
			]
		)

		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let cclService = CCLService(restServiceProvider, cclServiceMode: [.configuration], signatureVerifier: MockVerifier())
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

		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: [
				"ETag": eTag + "new"
			],
			responseData: cclConfigurationData
		)
		let cache = try cache(with: Locator.CCLConfiguration(isFake: false), eTag: eTag, date: yesterday, responseData: cclConfigurationData)
		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: cache)
		let cclService = CCLService(restServiceProvider, cclServiceMode: [.configuration], signatureVerifier: MockVerifier())
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

		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: [
				"ETag": eTag + "new"
			],
			responseData: cclConfigurationData
		)
		let cache = try cache(with: Locator.CCLConfiguration(isFake: false), eTag: eTag, date: today, responseData: cclConfigurationData)
		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: cache)
		let cclService = CCLService(restServiceProvider, cclServiceMode: [.configuration], signatureVerifier: MockVerifier())
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

	func testGIVEN_cachedCCLConfigurationWithOneVersion_WHEN_gettingVersion_THEN_versionIsCorrect() throws {
		// GIVEN
		let eTag = "DummyDataETag"
		let cclConfigurationData = try cclConfigurationData(
			identifiersAndVersions: [
				"CCL-DE-0001": "1.0.0"
			]
		)

		let cache = try cache(with: Locator.CCLConfiguration(isFake: false), eTag: eTag, date: today, responseData: cclConfigurationData)
		let restServiceProvider = RestServiceProvider(session: MockNetworkStack().urlSession, cache: cache)
		let cclService = CCLService(restServiceProvider, cclServiceMode: [.configuration], signatureVerifier: MockVerifier())

		// WHEN
		let version = cclService.configurationVersion

		// THEN
		XCTAssertEqual(version, "1.0.0")
	}

	func testGIVEN_cachedCCLConfigurationWithMultipleVersions_WHEN_gettingVersion_THEN_versionIsCorrect() throws {
		// GIVEN
		let eTag = "DummyDataETag"
		let cclConfigurationData = try cclConfigurationData(
			identifiersAndVersions: [
				"CCL-DE-0002": "1.0.1",
				"CCL-DE-0004": "1.2.5",
				"CCL-DE-0014": "1.0.37",
				"CCL-DE-0001": "1.0.0"
			]
		)

		let cache = try cache(with: Locator.CCLConfiguration(isFake: false), eTag: eTag, date: today, responseData: cclConfigurationData)
		let restServiceProvider = RestServiceProvider(session: MockNetworkStack().urlSession, cache: cache)
		let cclService = CCLService(restServiceProvider, cclServiceMode: [.configuration], signatureVerifier: MockVerifier())

		// WHEN
		let version = cclService.configurationVersion

		// THEN
		XCTAssertEqual(version, "1.0.0, 1.0.1, 1.2.5, 1.0.37")
	}

	func testGIVEN_newCCLConfiguration_WHEN_updatingConfiguration_THEN_versionIsUpdated() throws {
		// GIVEN
		let eTag = "DummyDataETag"
		let oldCCLConfigurationData = try cclConfigurationData(
			identifiersAndVersions: [
				"CCL-DE-0001": "1.0.0"
			]
		)

		let updatedCCLConfigurationData = try cclConfigurationData(
			identifiersAndVersions: [
				"CCL-DE-0003": "1.0.2",
				"CCL-DE-0005": "1.1.0"
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
		let cclService = CCLService(restServiceProvider, cclServiceMode: [.configuration], signatureVerifier: MockVerifier())
		let expectation = expectation(description: "update finished")

		// WHEN
		cclService.updateConfiguration { _ in
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .short)

		XCTAssertEqual(cclService.configurationVersion, "1.0.2, 1.1.0")
	}

	// MARK: - Helpers

	func cclConfigurationData() throws -> Data {
		return try XCTUnwrap(
			Archive.createArchiveData(
				accessMode: .create,
				cborData: HealthCertificateToolkit.CCLConfigurationCBORDataFake()
			)
		)
	}

	func cclConfigurationData(identifiersAndVersions: [String: String]) throws -> Data {
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

}
