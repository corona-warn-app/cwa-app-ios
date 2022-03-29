//
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
import ZIPFoundation
@testable import ENA

class CCLServiceInvalidationRulesTests: CCLServiceBaseTests {

	func invalidationRulesData() throws -> Data {
		return try XCTUnwrap(
			Archive.createArchiveData(
				accessMode: .create,
				cborData: HealthCertificateToolkit.rulesCBORDataFake()
			)
		)
	}

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
		let cclService = CCLService(restServiceProvider, appConfiguration: appConfiguration, cclServiceMode: [.invalidationRules], signatureVerifier: MockVerifier())
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

	func testGIVEN_cachedDataFromYesterDay_WHEN_200_THEN_didChangeIsTrue() throws {
		// GIVEN
		let eTag = "DummyDataETag"
		let invalidationRulesData = try invalidationRulesData()
		let appConfiguration = CachedAppConfigurationMock()
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: [
				"ETag": eTag + "new"
			],
			responseData: invalidationRulesData
		)
		let cache = try cache(with: Locator.DCCRules(ruleType: .invalidation, isFake: false), eTag: eTag, date: yesterday, responseData: invalidationRulesData)
		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: cache)
		let cclService = CCLService(restServiceProvider, appConfiguration: appConfiguration, cclServiceMode: [.invalidationRules], signatureVerifier: MockVerifier())
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

	func testGIVEN_cachedDataFromToday_WHEN_200_THEN_didChangeIsFalse() throws {
		// GIVEN
		let eTag = "DummyDataETag"
		let invalidationRulesData = try invalidationRulesData()
		let appConfiguration = CachedAppConfigurationMock()
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: [
				"ETag": eTag + "new"
			],
			responseData: invalidationRulesData
		)
		let cache = try cache(with: Locator.DCCRules(ruleType: .invalidation, isFake: false), eTag: eTag, date: today, responseData: invalidationRulesData)
		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: cache)
		let cclService = CCLService(restServiceProvider, appConfiguration: appConfiguration, cclServiceMode: [.invalidationRules], signatureVerifier: MockVerifier())
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
}
