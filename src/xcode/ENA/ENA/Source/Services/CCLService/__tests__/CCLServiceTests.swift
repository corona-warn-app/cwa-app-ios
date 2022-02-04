//
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
import ZIPFoundation
@testable import ENA

class CCLServiceTests: XCTestCase {

	// MARK: Helpers

	let today = Date()

	var yesterday: Date {
		guard let yesterday = date(hours: -1, fromDate: midnight) else {
			XCTFail("failed to created yesterday date for tests")
			return Date(timeInterval: -24 * 60 * 60, since: Date())
		}
		return yesterday
	}

	func date(day delta: Int) -> Date? {
		var component = DateComponents()
		component.day = delta
		return Calendar.current.date(byAdding: component, to: today)
	}

	func date(hours delta: Int, fromDate: Date? = nil) -> Date? {
		var component = DateComponents()
		component.hour = delta

		let date = fromDate ?? today
		return Calendar.current.date(byAdding: component, to: date)
	}

	var midnight: Date? {
		return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: today, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .backward)
	}

	func cache(
		with locator: Locator = .fake(),
		eTag: String = "DummyDataETag",
		date: Date = Date(),
		responseData: Data? = nil
	) throws -> KeyValueCacheFake {
		let cache = KeyValueCacheFake()
		if let responseData = responseData {
			cache[locator.hashValue] = CacheData(data: responseData, eTag: eTag, date: date)
		}
		return cache
	}

	func cclConfigurationData() throws -> Data {
		// GIVEN
		return try XCTUnwrap(
			Archive.createArchiveData(
				accessMode: .create,
				cborData: HealthCertificateToolkit.CCLConfigurationCBORDataFake()
			)
		)
	}

	// MARk: - Configuration logic on CCLService Layer

	func testGIVEN_emptyCache_WHEN_404_THEN_didChangeIsFalse() throws {
		let eTag = "DummyDataETag"
		let stack = MockNetworkStack(
			httpStatus: 404,
			headerFields: [
				"ETag": eTag
			]
		)

		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let cclService = CCLService(restServiceProvider, cclServiceMode: [.configuration], signatureVerifier: MockVerifier())

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

	func testGIVEN_cachedCCLConfigurationFromYesterDay_WHEN_200_THEN_didChangeIsTrue() throws {
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

	func testGIVEN_cachedCCLConfigurationFromToday_WHEN_200_THEN_didChangeIsFalse() throws {
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
