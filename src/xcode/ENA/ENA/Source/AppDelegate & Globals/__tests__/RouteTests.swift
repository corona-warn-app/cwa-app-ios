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

		// THEN
		guard
			case let .rapidAntigen(result) = route,
			case let .success(coronaTestRegistrationInformation) = result,
			case let .antigen(qrCodeInformation: antigenTestQRCodeInformation) = coronaTestRegistrationInformation
		else {
			XCTFail("unexpected route type")
			return
		}

		XCTAssertEqual(antigenTestQRCodeInformation.hash, "1ea4c222ff0c0e4ed7373f274caa7f75d10fccbdac56c632771cd9592102a555")
		XCTAssertEqual(antigenTestQRCodeInformation.timestamp, 1619617269)
		XCTAssertEqual(antigenTestQRCodeInformation.firstName, "Henry")
		XCTAssertEqual(antigenTestQRCodeInformation.lastName, "Pinzani")
		XCTAssertEqual(antigenTestQRCodeInformation.dateOfBirth, Date(timeIntervalSince1970: 620438400))
		XCTAssertEqual(antigenTestQRCodeInformation.testID, "b4a40c6c-e02c-4448-b8ab-0b5b7c34d60a")
		XCTAssertEqual(antigenTestQRCodeInformation.cryptographicSalt, "7BFA06B5AD9311B8719BB80661C54EAD")
		XCTAssertNil(antigenTestQRCodeInformation.certificateSupportedByPointOfCare)
	}

	func testGIVEN_validRATUrlWithDGCTrue_WHEN_parseRoute_THEN_isValid() {
		// GIVEN
		let validRATTestURL = "https://s.coronawarn.app?v=1#eyJ0aW1lc3RhbXAiOjE2MjI2MzA0NzAsInNhbHQiOiIzNDJGRDRGM0RFNzQwNjI5RjlDOTdGMkJCODUxMUJBQyIsInRlc3RpZCI6ImIxYmNkZWYzLTNjZGEtNDI0NS05ZTk2LTZkNzkzZWE4YjYwZCIsImhhc2giOiI2ODJlMzNmZDc3YmY1NzE5ZWYxNzZmYjRlN2ZjNzIzNzQ4NmQ2OGZjMTVkMDE2OTJjMDA0OWEyNGM2ZmE2NTYzIiwiZm4iOiJDbHlkZSIsImxuIjoiTW9udGlnaWFuaSIsImRvYiI6IjE5NTktMTAtMDIiLCJkZ2MiOnRydWV9"

		// WHEN
		let route = Route(validRATTestURL)

		// THEN
		guard
			case let .rapidAntigen(result) = route,
			case let .success(coronaTestRegistrationInformation) = result,
			case let .antigen(qrCodeInformation: antigenTestQRCodeInformation) = coronaTestRegistrationInformation
		else {
			XCTFail("unexpected route type")
			return
		}

		XCTAssertEqual(antigenTestQRCodeInformation.hash, "682e33fd77bf5719ef176fb4e7fc7237486d68fc15d01692c0049a24c6fa6563")
		XCTAssertEqual(antigenTestQRCodeInformation.timestamp, 1622630470)
		XCTAssertEqual(antigenTestQRCodeInformation.firstName, "Clyde")
		XCTAssertEqual(antigenTestQRCodeInformation.lastName, "Montigiani")
		XCTAssertEqual(antigenTestQRCodeInformation.dateOfBirth, Date(timeIntervalSince1970: -323481600))
		XCTAssertEqual(antigenTestQRCodeInformation.testID, "b1bcdef3-3cda-4245-9e96-6d793ea8b60d")
		XCTAssertEqual(antigenTestQRCodeInformation.cryptographicSalt, "342FD4F3DE740629F9C97F2BB8511BAC")
		XCTAssertTrue(try XCTUnwrap(antigenTestQRCodeInformation.certificateSupportedByPointOfCare))
	}

	func testGIVEN_validRATUrlWithDGCFalse_WHEN_parseRoute_THEN_isValid() {
		// GIVEN
		let validRATTestURL = "https://s.coronawarn.app?v=1#eyJ0aW1lc3RhbXAiOjE2MjI2MzA2NTQsInNhbHQiOiJBQzgxMTIyOUI3OTIzRjFBOEUwNTMwQ0M2ODlBQzBDQyIsInRlc3RpZCI6IjJhOTJmMGZiLWYzN2UtNDhkMy1hMzE5LWJjYTA0MWE4ZGIwMSIsImhhc2giOiJjYTljZTBjZTE5NTE1MmFkMWMzMDkwNzIyYTU0ZGJiNzNmZDdlMTM3NzdlZTdiYWUxZWEwNGM0MzU0YjcwYjUwIiwiZm4iOiJHYXJyZXR0IiwibG4iOiJDYW1wYmVsbCIsImRvYiI6IjE5ODctMDctMDIiLCJkZ2MiOmZhbHNlfQ=="

		// WHEN
		let route = Route(validRATTestURL)

		// THEN
		guard
			case let .rapidAntigen(result) = route,
			case let .success(coronaTestRegistrationInformation) = result,
			case let .antigen(qrCodeInformation: antigenTestQRCodeInformation) = coronaTestRegistrationInformation
		else {
			XCTFail("unexpected route type")
			return
		}

		XCTAssertEqual(antigenTestQRCodeInformation.hash, "ca9ce0ce195152ad1c3090722a54dbb73fd7e13777ee7bae1ea04c4354b70b50")
		XCTAssertEqual(antigenTestQRCodeInformation.timestamp, 1622630654)
		XCTAssertEqual(antigenTestQRCodeInformation.firstName, "Garrett")
		XCTAssertEqual(antigenTestQRCodeInformation.lastName, "Campbell")
		XCTAssertEqual(antigenTestQRCodeInformation.dateOfBirth, Date(timeIntervalSince1970: 552182400))
		XCTAssertEqual(antigenTestQRCodeInformation.testID, "2a92f0fb-f37e-48d3-a319-bca041a8db01")
		XCTAssertEqual(antigenTestQRCodeInformation.cryptographicSalt, "AC811229B7923F1A8E0530CC689AC0CC")
		XCTAssertFalse(try XCTUnwrap(antigenTestQRCodeInformation.certificateSupportedByPointOfCare))
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
