////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class RouteTests: CWATestCase {

	func testGIVEN_validRATUrlWithoutDGCInfo_WHEN_parseRoute_THEN_isValid() {
		// GIVEN
		let validRATTestURL = "https://s.coronawarn.app?v=1#eyJ0aW1lc3RhbXAiOjE2MTk2MTcyNjksInNhbHQiOiI3QkZBMDZCNUFEOTMxMUI4NzE5QkI4MDY2MUM1NEVBRCIsInRlc3RpZCI6ImI0YTQwYzZjLWUwMmMtNDQ0OC1iOGFiLTBiNWI3YzM0ZDYwYSIsImhhc2giOiIxZWE0YzIyMmZmMGMwZTRlZDczNzNmMjc0Y2FhN2Y3NWQxMGZjY2JkYWM1NmM2MzI3NzFjZDk1OTIxMDJhNTU1IiwiZm4iOiJIZW5yeSIsImxuIjoiUGluemFuaSIsImRvYiI6IjE5ODktMDgtMzAifQ"

		// WHEN
		let route = Route(validRATTestURL)
		guard case let .rapidAntigen(result) = route else {
			XCTFail("unexpected route type")
			return
		}

		// THEN
		switch result {
		case .success:
			break
		case .failure:
			XCTFail("Error was not intended")
		}
	}

	func testGIVEN_validRATUrlWithDGCTrue_WHEN_parseRoute_THEN_isValid() {
		// GIVEN
		let validRATTestURL = "https://s.coronawarn.app?v=1#eyJ0aW1lc3RhbXAiOjE2MjI2MzA0NzAsInNhbHQiOiIzNDJGRDRGM0RFNzQwNjI5RjlDOTdGMkJCODUxMUJBQyIsInRlc3RpZCI6ImIxYmNkZWYzLTNjZGEtNDI0NS05ZTk2LTZkNzkzZWE4YjYwZCIsImhhc2giOiI2ODJlMzNmZDc3YmY1NzE5ZWYxNzZmYjRlN2ZjNzIzNzQ4NmQ2OGZjMTVkMDE2OTJjMDA0OWEyNGM2ZmE2NTYzIiwiZm4iOiJDbHlkZSIsImxuIjoiTW9udGlnaWFuaSIsImRvYiI6IjE5NTktMTAtMDIiLCJkZ2MiOnRydWV9"

		// WHEN
		let route = Route(validRATTestURL)
		guard case let .rapidAntigen(result) = route else {
			XCTFail("unexpected route type")
			return
		}

		// THEN
		switch result {
		case .success:
			break
		case .failure:
			XCTFail("Error was not intended")
		}
	}

	func testGIVEN_validRATUrlWithDGCFalse_WHEN_parseRoute_THEN_isValid() {
		// GIVEN
		let validRATTestURL = "https://s.coronawarn.app?v=1#eyJ0aW1lc3RhbXAiOjE2MjI2MzA2NTQsInNhbHQiOiJBQzgxMTIyOUI3OTIzRjFBOEUwNTMwQ0M2ODlBQzBDQyIsInRlc3RpZCI6IjJhOTJmMGZiLWYzN2UtNDhkMy1hMzE5LWJjYTA0MWE4ZGIwMSIsImhhc2giOiJjYTljZTBjZTE5NTE1MmFkMWMzMDkwNzIyYTU0ZGJiNzNmZDdlMTM3NzdlZTdiYWUxZWEwNGM0MzU0YjcwYjUwIiwiZm4iOiJHYXJyZXR0IiwibG4iOiJDYW1wYmVsbCIsImRvYiI6IjE5ODctMDctMDIiLCJkZ2MiOmZhbHNlfQ=="

		// WHEN
		let route = Route(validRATTestURL)
		guard case let .rapidAntigen(result) = route else {
			XCTFail("unexpected route type")
			return
		}

		// THEN
		switch result {
		case .success:
			break
		case .failure:
			XCTFail("Error was not intended")
		}
	}

	func testGIVEN_invalidRATUrl_WHEN_parseRoute_THEN_isValid() {
		// GIVEN
		let validRATTestURL = "https://s.coronawarn.app?v=1#eJ0aW1lc3RhbXAiOjE2MTg0ODI2MzksImd1aWQiOiIzM0MxNDNENS0yMTgyLTQ3QjgtOTM4NS02ODBGMzE4RkU0OTMiLCJmbiI6IlJveSIsImxuIjoiRnJhc3NpbmV0aSIsImRvYiI6IjE5ODEtMTItMDEifQ=="

		// WHEN
		let route = Route(validRATTestURL)
		guard case let .rapidAntigen(result) = route else {
			XCTFail("unexpected route type")
			return
		}

		// THEN
		switch result {
		case .success:
			XCTFail("Route parse success wasn't expected")
		case .failure:
			break
		}
	}

}
