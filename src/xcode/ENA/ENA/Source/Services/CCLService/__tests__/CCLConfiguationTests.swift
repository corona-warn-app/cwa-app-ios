//
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
import ZIPFoundation
import jsonfunctions
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
		let resource = CCLConfigurationResource(mockDefaultModel: CCLConfigurationReceiveModel([]))

		let cclService = CCLService(
			restServiceProvider,
			appConfiguration: appConfiguration,
			cclServiceMode: [.configuration],
			signatureVerifier: MockVerifier(),
			cclConfigurationResource: resource
		)

		// WHEN
		let version = cclService.configurationVersion

		// THEN
		XCTAssertEqual(version, "Cached-Version")
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
		let resource = CCLConfigurationResource(mockDefaultModel: CCLConfigurationReceiveModel([]))

		let cclService = CCLService(
			restServiceProvider,
			appConfiguration: appConfiguration,
			cclServiceMode: [.configuration],
			signatureVerifier: MockVerifier(),
			cclConfigurationResource: resource
		)

		// WHEN
		let version = cclService.configurationVersion

		// THEN
		XCTAssertEqual(version, "1.0.0, 1.0.1, 1.2.5, 1.0.37")
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
		let resource = CCLConfigurationResource(mockDefaultModel: CCLConfigurationReceiveModel([]))

		let cclService = CCLService(
			restServiceProvider,
			appConfiguration: appConfiguration,
			cclServiceMode: [.configuration],
			signatureVerifier: MockVerifier(),
			cclConfigurationResource: resource
		)

		let expectation = expectation(description: "update finished")

		// WHEN
		cclService.updateConfiguration { _ in
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .short)

		XCTAssertEqual(cclService.configurationVersion, "1.0.2, 1.1.0")
	}

	func testGIVEN_cachedCCLConfigurationWithOnlyOneDefaultVersion_WHEN_gettingVersion_THEN_versionIsCorrect() throws {
		// GIVEN
		let appConfiguration = CachedAppConfigurationMock()
		let cache = try cache()
		let restServiceProvider = RestServiceProvider(session: MockNetworkStack().urlSession, cache: cache)

		let resource = CCLConfigurationResource(
			mockDefaultModel: CCLConfigurationReceiveModel([
				.fake(identifier: "CCL-Default-Configuration", version: "DefaultVersion-1.0.0")
			])
		)

		let cclService = CCLService(
			restServiceProvider,
			appConfiguration: appConfiguration,
			cclServiceMode: [.configuration],
			signatureVerifier: MockVerifier(),
			cclConfigurationResource: resource
		)

		// WHEN
		let version = cclService.configurationVersion

		// THEN
		XCTAssertEqual(version, "DefaultVersion-1.0.0")
	}

	func testGIVEN_cachedCCLConfigurationWithMultipleDefaultVersions_WHEN_gettingVersion_THEN_versionIsCorrect() throws {
		// GIVEN
		let appConfiguration = CachedAppConfigurationMock()
		let cache = try cache()
		let restServiceProvider = RestServiceProvider(session: MockNetworkStack().urlSession, cache: cache)

		let resource = CCLConfigurationResource(
			mockDefaultModel: CCLConfigurationReceiveModel([
				.fake(identifier: "Second-CCL-Default-Configuration", version: "AnotherDefaultVersion-2.5.0alpha"),
				.fake(identifier: "CCL-Default-Configuration", version: "DefaultVersion-1.0.0")
			])
		)

		let cclService = CCLService(
			restServiceProvider,
			appConfiguration: appConfiguration,
			cclServiceMode: [.configuration],
			signatureVerifier: MockVerifier(),
			cclConfigurationResource: resource
		)

		// WHEN
		let version = cclService.configurationVersion

		// THEN
		XCTAssertEqual(version, "DefaultVersion-1.0.0, AnotherDefaultVersion-2.5.0alpha")
	}

	func testGIVEN_cachedCCLConfigurationSameAsDefaultVersion_WHEN_gettingVersion_THEN_versionIsCorrect() throws {
		// GIVEN
		let eTag = "DummyDataETag"
		let cclConfigurationData = try cclConfigurationData(
			identifiersAndVersions: [
				"CCL-Default-Configuration": "DefaultVersion-1.0.0"
			]
		)
		let appConfiguration = CachedAppConfigurationMock()

		let cache = try cache(with: Locator.CCLConfiguration(isFake: false), eTag: eTag, date: today, responseData: cclConfigurationData)
		let restServiceProvider = RestServiceProvider(session: MockNetworkStack().urlSession, cache: cache)

		let resource = CCLConfigurationResource(
			mockDefaultModel: CCLConfigurationReceiveModel([
				.fake(identifier: "CCL-Default-Configuration", version: "DefaultVersion-1.0.0")
			])
		)

		let cclService = CCLService(
			restServiceProvider,
			appConfiguration: appConfiguration,
			cclServiceMode: [.configuration],
			signatureVerifier: MockVerifier(),
			cclConfigurationResource: resource
		)

		// WHEN
		let version = cclService.configurationVersion

		// THEN
		XCTAssertEqual(version, "DefaultVersion-1.0.0")
	}

	func testGIVEN_multipleCachedCCLConfigurationsSameAsDefaultVersions_WHEN_gettingVersion_THEN_versionIsCorrect() throws {
		// GIVEN
		let eTag = "DummyDataETag"
		let cclConfigurationData = try cclConfigurationData(
			identifiersAndVersions: [
				"CCL-Default-Configuration": "DefaultVersion-1.0.0",
				"Second-CCL-Default-Configuration": "AnotherDefaultVersion-2.5.0alpha"
			]
		)
		let appConfiguration = CachedAppConfigurationMock()

		let cache = try cache(with: Locator.CCLConfiguration(isFake: false), eTag: eTag, date: today, responseData: cclConfigurationData)
		let restServiceProvider = RestServiceProvider(session: MockNetworkStack().urlSession, cache: cache)

		let resource = CCLConfigurationResource(
			mockDefaultModel: CCLConfigurationReceiveModel([
				.fake(identifier: "Second-CCL-Default-Configuration", version: "AnotherDefaultVersion-2.5.0alpha"),
				.fake(identifier: "CCL-Default-Configuration", version: "DefaultVersion-1.0.0")
			])
		)

		let cclService = CCLService(
			restServiceProvider,
			appConfiguration: appConfiguration,
			cclServiceMode: [.configuration],
			signatureVerifier: MockVerifier(),
			cclConfigurationResource: resource
		)

		// WHEN
		let version = cclService.configurationVersion

		// THEN
		XCTAssertEqual(version, "DefaultVersion-1.0.0, AnotherDefaultVersion-2.5.0alpha")
	}

	func testGIVEN_defaultConfigurationsContainConfigurationNotInCache_WHEN_gettingVersion_THEN_missingDefaultConfigurationIsConsidered() throws {
		// GIVEN
		let eTag = "DummyDataETag"

		let cachedFunctionDescriptorString = """
		{
			"name": "cachedFunction",
			"definition": {
				"parameters": [],
				"logic": [
					{
						"return": [
							"cachedReturnValue"
						]
					}
				]
			}
		}
		"""

		let cachedFunctionDescriptor = try JSONDecoder().decode(JsonFunctionDescriptor.self, from: Data(cachedFunctionDescriptorString.utf8))

		let cclConfigurationData = try cclConfigurationData(
			for: [
				.fake(
					identifier: "CCL-Default-Configuration",
					version: "DefaultVersion-1.0.0",
					logic: .fake(jfnDescriptors: [cachedFunctionDescriptor])
				)
			]
		)
		let appConfiguration = CachedAppConfigurationMock()

		let cache = try cache(with: Locator.CCLConfiguration(isFake: false), eTag: eTag, date: today, responseData: cclConfigurationData)
		let restServiceProvider = RestServiceProvider(session: MockNetworkStack().urlSession, cache: cache)

		let defaultFunctionDescriptorString = """
		{
			"name": "defaultFunction",
			"definition": {
				"parameters": [],
				"logic": [
					{
						"return": [
							"defaultReturnValue"
						]
					}
				]
			}
		}
		"""

		let defaultFunctionDescriptor = try JSONDecoder().decode(JsonFunctionDescriptor.self, from: Data(defaultFunctionDescriptorString.utf8))

		let resource = CCLConfigurationResource(
			mockDefaultModel: CCLConfigurationReceiveModel([
				.fake(
					identifier: "Second-CCL-Default-Configuration",
					version: "AnotherDefaultVersion-2.5.0alpha",
					logic: .fake(jfnDescriptors: [defaultFunctionDescriptor])
				),
				.fake(identifier: "CCL-Default-Configuration", version: "DefaultVersion-1.0.0")
			])
		)

		let cclService = CCLService(
			restServiceProvider,
			appConfiguration: appConfiguration,
			cclServiceMode: [.configuration],
			signatureVerifier: MockVerifier(),
			cclConfigurationResource: resource
		)

		// WHEN
		let version = cclService.configurationVersion
		let cachedReturnValue: String = try cclService.evaluateFunctionWithDefaultValues(name: "cachedFunction", parameters: [:])
		let defaultReturnValue: String = try cclService.evaluateFunctionWithDefaultValues(name: "defaultFunction", parameters: [:])

		// THEN
		XCTAssertEqual(version, "DefaultVersion-1.0.0, AnotherDefaultVersion-2.5.0alpha")
		XCTAssertEqual(cachedReturnValue, "cachedReturnValue")
		XCTAssertEqual(defaultReturnValue, "defaultReturnValue")
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

	private func cclConfigurationData(for configurations: [CCLConfiguration]) throws -> Data {
		try XCTUnwrap(
			Archive.createArchiveData(
				accessMode: .create,
				cborData: HealthCertificateToolkit.CCLConfigurationCBORDataFake(configs: configurations)
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

}
