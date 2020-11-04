import XCTest
@testable import ENA

class CountryTests: XCTestCase {

	/// Identifier for the 'EU' region and coutries
	let allCountryIDs = ["EU", "DE", "UK", "FR", "IT", "ES", "PL", "RO", "NL", "BE", "CZ", "EL", "SE", "PT", "HU", "AT", "CH", "BG", "DK", "FI", "SK", "NO", "IE", "HR", "SI", "LT", "LV", "EE", "CY", "LU", "MT", "IS"]

    func testCountryInit() throws {
		for id in allCountryIDs {
			// should init
			let country = try XCTUnwrap(Country(countryCode: id), "unwrap failed for \(id)")

			// has flag asset?
			XCTAssertNotNil(country.flag)
		}
    }

	func testDefaultCountry() throws {
		XCTAssertNoThrow(Country.defaultCountry(), "")
		let country = Country.defaultCountry()
		XCTAssertEqual(country.id, "DE", "assuming Germany/DE to be default")
	}

	func testInvalidCountryCodes() throws {
		let invalid = ["SP", "XX", ""]
		for code in invalid {
			XCTAssertNil(Country(countryCode: code))
		}
	}

	func testInvalidCountryRegionName() throws {
		XCTAssertNil(Locale.current.regionName(forCountryCode: ""))
	}
}
