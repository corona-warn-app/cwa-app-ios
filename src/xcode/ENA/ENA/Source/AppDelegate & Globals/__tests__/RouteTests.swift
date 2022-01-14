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
			case let .antigen(qrCodeInformation: antigenTestQRCodeInformation, qrCodeHash: _) = coronaTestRegistrationInformation
		else {
			XCTFail("unexpected route type")
			return
		}

		XCTAssertEqual(route?.routeInformation, .rapidAntigenTest)
		XCTAssertEqual(antigenTestQRCodeInformation.hash, "1ea4c222ff0c0e4ed7373f274caa7f75d10fccbdac56c632771cd9592102a555")
		XCTAssertEqual(antigenTestQRCodeInformation.timestamp, 1619617269)
		XCTAssertEqual(antigenTestQRCodeInformation.firstName, "Henry")
		XCTAssertEqual(antigenTestQRCodeInformation.lastName, "Pinzani")
		XCTAssertEqual(antigenTestQRCodeInformation.dateOfBirth, Date(timeIntervalSince1970: 620438400))
		XCTAssertEqual(antigenTestQRCodeInformation.testID, "b4a40c6c-e02c-4448-b8ab-0b5b7c34d60a")
		XCTAssertEqual(antigenTestQRCodeInformation.cryptographicSalt, "7BFA06B5AD9311B8719BB80661C54EAD")
		XCTAssertNil(antigenTestQRCodeInformation.certificateSupportedByPointOfCare)
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
		XCTAssertEqual(route?.routeInformation, .rapidAntigenTest)
		switch result {
		case .success:
			XCTFail("Route parse success wasn't expected")
		case .failure:
			break
		}
	}

	func testGIVEN_InvalidURLString_WHEN_createRoute_THEN_RouteIsNil() {
		// GIVEN
		let invalidRATTestURL = "http:s.coronawarn.app?v=1#eJ0aW1lc3RhbXAiOjE2MTg0ODI2MzksImd1aWQiOiIzM0MxNDNENS0yMTgyLTQ3QjgtOTM4NS02ODBGMzE4RkU0OTMiLCJmbiI6IlJveSIsImxuIjoiRnJhc3NpbmV0aSIsImRvYiI6IjE5ODEtMTItMDEifQ=="

		// WHEN
		let route = Route(invalidRATTestURL)

		// THEN
		XCTAssertNil(route)
	}

	func testGIVEN_InvalidTestInformation_WHEN_Route_THEN_FailureInvalidHash() throws {
		// GIVEN
		let antigenTest = AntigenTestQRCodeInformation.mock(
			hash: "1ea4c222ff0c0e4ed7373f274caa7f75d10fccbdac56c632771cd9592102a55",
			timestamp: 1619617269,
			firstName: "Henry",
			lastName: "Pinzani",
			cryptographicSalt: "7BFA06B5AD9311B8719BB80661C54EAD",
			testID: "b4a40c6c-e02c-4448-b8ab-0b5b7c34d60a",
			dateOfBirth: Date(timeIntervalSince1970: 620438400),
			certificateSupportedByPointOfCare: true
		)

		let jsonData = try JSONEncoder().encode(antigenTest)
		let base64 = jsonData.base64EncodedString()
		let url = try XCTUnwrap(URLComponents(string: String(format: "https://s.coronawarn.app?v=1#%@", base64))?.url)

		// WHEN
		let route = Route(url: url)

		// THEN
		XCTAssertEqual(route?.routeInformation, .rapidAntigenTest)
		XCTAssertEqual(route, .rapidAntigen(.failure(.invalidTestCode(.invalidHash))))
	}

	func testGIVEN_InvalidTestInformation_WHEN_Route_THEN_FailureInvalidTimeStamp() throws {
		// GIVEN
		let antigenTest = AntigenTestQRCodeInformation.mock(
			hash: "1ea4c222ff0c0e4ed7373f274caa7f75d10fccbdac56c632771cd9592102a555",
			timestamp: -5,
			firstName: "Henry",
			lastName: "Pinzani",
			cryptographicSalt: "7BFA06B5AD9311B8719BB80661C54EAD",
			testID: "b4a40c6c-e02c-4448-b8ab-0b5b7c34d60a",
			dateOfBirth: Date(timeIntervalSince1970: 620438400),
			certificateSupportedByPointOfCare: true
		)

		let jsonData = try JSONEncoder().encode(antigenTest)
		let base64 = jsonData.base64EncodedString()
		let url = try XCTUnwrap(URLComponents(string: String(format: "https://s.coronawarn.app?v=1#%@", base64))?.url)

		// WHEN
		let route = Route(url: url)

		// THEN
		XCTAssertEqual(route?.routeInformation, .rapidAntigenTest)
		XCTAssertEqual(route, .rapidAntigen(.failure(.invalidTestCode(.invalidTimeStamp))))
	}

	func testGIVEN_InvalidTestInformation_WHEN_URLWithMissingV1_THEN_RouteIsNil() throws {
		// GIVEN
		let antigenTest = AntigenTestQRCodeInformation.mock(
			hash: "1ea4c222ff0c0e4ed7373f274caa7f75d10fccbdac56c632771cd9592102a555",
			timestamp: 1619617269,
			firstName: "Henry",
			lastName: "Pinzani",
			cryptographicSalt: "7BFA06B5AD9311B8719BB80661C54EAD",
			testID: "b4a40c6c-e02c-4448-b8ab-0b5b7c34d60a",
			dateOfBirth: Date(timeIntervalSince1970: 620438400),
			certificateSupportedByPointOfCare: true
		)

		let jsonData = try JSONEncoder().encode(antigenTest)
		let base64 = jsonData.base64EncodedString()
		let url = try XCTUnwrap(URLComponents(string: String(format: "https://s.coronawarn.app#%@", base64))?.url)

		// WHEN
		let route = Route(url: url)

		// THEN
		XCTAssertNil(route)
	}

	func testGIVEN_InvalidTestInformation_WHEN_FirstNameLastNameMiggingButDateOfBirthIsGiven_THEN_FailureInvalidTestedPersonInformation() throws {
		// GIVEN
		let antigenTest = AntigenTestQRCodeInformation.mock(
			hash: "1ea4c222ff0c0e4ed7373f274caa7f75d10fccbdac56c632771cd9592102a555",
			timestamp: 1619617269,
			firstName: nil,
			lastName: nil,
			cryptographicSalt: "7BFA06B5AD9311B8719BB80661C54EAD",
			testID: "b4a40c6c-e02c-4448-b8ab-0b5b7c34d60a",
			dateOfBirth: Date(timeIntervalSince1970: 620438400),
			certificateSupportedByPointOfCare: true
		)

		let jsonData = try JSONEncoder().encode(antigenTest)
		let base64 = jsonData.base64EncodedString()
		let url = try XCTUnwrap(URLComponents(string: String(format: "https://s.coronawarn.app?v=1#%@", base64))?.url)

		// WHEN
		let route = Route(url: url)

		// THEN
		XCTAssertEqual(route?.routeInformation, .rapidAntigenTest)
		XCTAssertEqual(route, .rapidAntigen(.failure(.invalidTestCode(.invalidTestedPersonInformation))))
	}

	func testGIVEN_nonPersonalizedCodeURL_WHEN_Route_THEN_Succeed() throws {
		// GIVEN
		let url = "https://s.coronawarn.app?v=1#eyJ0aW1lc3RhbXAiOjE2Mjc0MDM4MDEsInNhbHQiOiJEQkFDOUU5ODNGQkVDRDc5RDRERkIzMzI3MTUyN0M2NyIsInRlc3RpZCI6ImE5NjIyMjlmLTg3M2EtNDAyNy05NjUxLWJlNWJhZTZkNzVjNSIsImhhc2giOiI1ZGI3ZGI5OGZhMGM2NDYxMWJhZDdhMmQxYzk4MGE1MDc4MzZiM2ZiZWIzNzNiMWNlMGMwNGNmNmUxNjYzNDExIn0"
		
		// WHEN
		let testInformation = try XCTUnwrap(AntigenTestQRCodeInformation(
												hash: "5db7db98fa0c64611bad7a2d1c980a507836b3fbeb373b1ce0c04cf6e1663411",
												timestamp: 1627403801,
												firstName: nil,
												lastName: nil,
												dateOfBirth: nil,
												testID: "a962229f-873a-4027-9651-be5bae6d75c5",
												cryptographicSalt: "DBAC9E983FBECD79D4DFB33271527C67",
												certificateSupportedByPointOfCare: nil
		))
		let route = try XCTUnwrap(Route(url))

		// THEN
		XCTAssertEqual(route.routeInformation, .rapidAntigenTest)
		switch route {
		case .rapidAntigen(.success(let test)):
			switch test {
			case .antigen(qrCodeInformation: let qrCodeInformation, qrCodeHash: _):
				XCTAssertEqual(testInformation, qrCodeInformation)
			case .pcr, .teleTAN:
				XCTFail("Wrong test. Expected Antigen")
			}
		default:
			XCTFail("Wrong route. Expected .rapidAntigen")
		}
	}
	
	func testGIVEN_manipulatedNonPersonalizedCodeURL_WHEN_Route_THEN_Fails() throws {
		// GIVEN
		let url = "https://s.coronawarn.app?v=1#eyJ0aW1lc3RhbXAiOjE2Mjc0NjAyNjAsInNhbHQiOiI1OTQyOTAxRDY1OEVBNDNENTk2ODI5REZEREY4QUY3NSIsInRlc3RpZCI6IjQyMGYwNzY1LWYzYWUtNGVhYy05ZTZiLTQ1MDRkNTk5NjIzMyIsImhhc2giOiI2NWVlMDVjMDZhODMzNjJjYzM2NTMxNDFmNDY0ODkwODRmZjA5NDQwZGI0OGZhYzU1MGMxOTZmZWI4NzkyOGMwIn0"
		
		// WHEN
		let route = try XCTUnwrap(Route(url))

		// THEN
		XCTAssertEqual(route.routeInformation, .rapidAntigenTest)
		switch route {
		case .rapidAntigen(.failure(.invalidTestCode(let error))):
			XCTAssertEqual(error, .hashMismatch)
		default:
			XCTFail("Wrong route. Expected .rapidAntigen")
		}
	}
	
	func testGIVEN_HealthCertifiedPersonAndCertificate_WHEN_RouteIsCreated_THEN_PropertiesAreSetCorrect() {
		
		// GIVEN
		let healthCertificate = HealthCertificate.mock()
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		
		// WHEN
		let route = Route(
			healthCertifiedPerson: healthCertifiedPerson,
			healthCertificate: healthCertificate
		)
		
		// THEN
		XCTAssertEqual(route.routeInformation, .healthCertificate)
		if case let .healthCertificateFromNotification(person, certificate) = route {
			XCTAssertEqual(person, healthCertifiedPerson)
			XCTAssertEqual(certificate, healthCertificate)
		} else {
			XCTFail("Test should not fail")
		}
	}
	
	func testGIVEN_HealthCertifiedPerson_WHEN_RouteIsCreated_THEN_PropertiesAreSetCorrect() {
		
		// GIVEN
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [])
		
		// WHEN
		let route = Route(
			healthCertifiedPerson: healthCertifiedPerson
		)
		
		// THEN
		XCTAssertEqual(route.routeInformation, .healthCertifiedPerson)
		if case let .healthCertifiedPersonFromNotification(person) = route {
			XCTAssertEqual(person, healthCertifiedPerson)
		} else {
			XCTFail("Test should not fail")
		}
	}
	
	func testGIVEN_Checkin_WHEN_RouteIsCreated_THEN_PropertiesAreSetCorrect() throws {
		
		// GIVEN
		let checkinURL = try XCTUnwrap(URL(string: "https://e.coronawarn.app"))
		
		// WHEN
		let route = Route(url: checkinURL)
		
		// THEN
		XCTAssertEqual(route?.routeInformation, .checkIn)
		if case let .checkIn(checkin) = route {
			XCTAssertEqual(checkin, checkinURL.absoluteString)
		} else {
			XCTFail("Test should not fail")
		}
	}
}
