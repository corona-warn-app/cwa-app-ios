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
}
