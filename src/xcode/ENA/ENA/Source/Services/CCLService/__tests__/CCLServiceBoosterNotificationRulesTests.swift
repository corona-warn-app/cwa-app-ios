//
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
import ZIPFoundation
@testable import ENA

class CCLServiceBoosterNotificationRulesTests: CCLServiceBaseTests {

	func boosterRulesData() throws -> Data {
		// GIVEN
		return try XCTUnwrap(
			Archive.createArchiveData(
				accessMode: .create,
				cborData: HealthCertificateToolkit.rulesCBORDataFake()
			)
		)
	}

	func testGIVEN_emptyCache_WHEN_404_THEN_didChangeIsFalse() throws {
		let eTag = "DummyDataETag"
		let stack = MockNetworkStack(
			httpStatus: 404,
			headerFields: [
				"ETag": eTag
			]
		)

		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let cclService = CCLService(restServiceProvider, cclServiceMode: [.boosterRules], signatureVerifier: MockVerifier())

		// WHEN
		let expectation = expectation(description: "update finished")
		var result: Bool = false
		cclService.updateConfiguration { didChange in
			result = didChange
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: .short)
		XCTAssertFalse(result)
	}

	func testGIVEN_cachedDataFromYesterDay_WHEN_200_THEN_didChangeIsTrue() throws {
		let eTag = "DummyDataETag"
		let boosterRulesData = try boosterRulesData()

		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: [
				"ETag": eTag + "new"
			],
			responseData: boosterRulesData
		)
		let cache = try cache(with: Locator.DCCRules(ruleType: .boosterNotification, isFake: false), eTag: eTag, date: yesterday, responseData: boosterRulesData)
		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: cache)
		let cclService = CCLService(restServiceProvider, cclServiceMode: [.boosterRules], signatureVerifier: MockVerifier())

		// WHEN
		let expectation = expectation(description: "update finished")
		var result: Bool = false
		cclService.updateConfiguration { didChange in
			result = didChange
			expectation.fulfill()
		}

		waitForExpectations(timeout: .short)
		XCTAssertTrue(result)
	}

	func testGIVEN_cachedDataFromToday_WHEN_200_THEN_didChangeIsFalse() throws {
		let eTag = "DummyDataETag"
		let boosterRulesData = try boosterRulesData()

		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: [
				"ETag": eTag + "new"
			],
			responseData: boosterRulesData
		)
		let cache = try cache(with: Locator.DCCRules(ruleType: .boosterNotification, isFake: false), eTag: eTag, date: today, responseData: boosterRulesData)
		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: cache)
		let cclService = CCLService(restServiceProvider, cclServiceMode: [.boosterRules], signatureVerifier: MockVerifier())

		// WHEN
		let expectation = expectation(description: "update finished")
		var result: Bool = false
		cclService.updateConfiguration { didChange in
			result = didChange
			expectation.fulfill()
		}

		waitForExpectations(timeout: .short)
		XCTAssertFalse(result)
	}
}
