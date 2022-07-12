//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class CountryTests: CWATestCase {

	/// Identifier for the 'EU' region and countries
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
	
	func testSortingOfCountries() throws {
	
		// GIVEN
		var unsortedList = [Country]()
		unsortedList.append(Country(countryCode: "FR") ?? Country.defaultCountry())
		unsortedList.append(Country(countryCode: "DE") ?? Country.defaultCountry())
		unsortedList.append(Country(countryCode: "CY") ?? Country.defaultCountry())
		unsortedList.append(Country(countryCode: "DK") ?? Country.defaultCountry())
		
		// WHEN
		let sortedList = unsortedList.sortedByLocalizedName
		
		// THEN
		switch Locale.current.languageCode {
		case "de":
			XCTAssertEqual(sortedList[0].id, "DK")
			XCTAssertEqual(sortedList[1].id, "DE")
			XCTAssertEqual(sortedList[2].id, "FR")
			XCTAssertEqual(sortedList[3].id, "CY")
		case "tr":
			XCTAssertEqual(sortedList[0].id, "DE")
			XCTAssertEqual(sortedList[1].id, "DK")
			XCTAssertEqual(sortedList[2].id, "FR")
			XCTAssertEqual(sortedList[3].id, "CY")
		case "en", "ro", "pl":
			XCTAssertEqual(sortedList[0].id, "CY")
			XCTAssertEqual(sortedList[1].id, "DK")
			XCTAssertEqual(sortedList[2].id, "FR")
			XCTAssertEqual(sortedList[3].id, "DE")
		default:
			XCTFail("unknown language code")
		}
	}

	func testSameCountryDifferentLocalizations_ResultIsEqual() throws {
		let german = Country(id: "DE", localizedName: "Deutschland")
		let english = Country(id: "DE", localizedName: "Germany")
		XCTAssertEqual(german, english)
	}

	func testDifferentCountriesButSameLocalization_ResultIsNotEqual() throws {
		let france = Country(id: "FR", localizedName: "notImportant")
		let germany = Country(id: "DE", localizedName: "notImportant")
		XCTAssertNotEqual(france, germany)
	}

}
