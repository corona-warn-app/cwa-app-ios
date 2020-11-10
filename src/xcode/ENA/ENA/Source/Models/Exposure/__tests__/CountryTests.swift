//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

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
