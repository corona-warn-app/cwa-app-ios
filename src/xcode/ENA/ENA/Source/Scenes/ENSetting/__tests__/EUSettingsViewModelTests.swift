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

import Foundation
import Combine
import XCTest
@testable import ENA

class EUSettingsViewModelTests: XCTestCase {

	private var subscriptions = Set<AnyCancellable>()
	private lazy var testCountries: [Country] = {
		[
			Country(countryCode: "UK"),
			Country(countryCode: "BE"),
			Country(countryCode: "DK"),
			Country(countryCode: "CZ")
		].compactMap { $0 }
	}()

	func testCountrySwitchOn() {
		let model = EUSettingsViewModel(
			countries: testCountries,
			euTracingSettings: EUTracingSettings(
				isAllCountriesEnbled: false,
				enabledCountries: ["BE", "DK"]
			)
		)

		let expectation = self.expectation(description: "did receive model update")
		model.$euTracingSettings
			.dropFirst()
			.prefix(1)
			.sink { settings in
				XCTAssertFalse(settings.isAllCountriesEnbled)
				XCTAssert(settings.enabledCountries.contains("UK"))
				expectation.fulfill()
			}
			.store(in: &subscriptions)

		model.countryModels.first { $0.country.id == "UK" }?.isOn = true
		waitForExpectations(timeout: .short)
	}

	func testCountrySwitchOff() {
		let model = EUSettingsViewModel(
			countries: testCountries,
			euTracingSettings: EUTracingSettings(
				isAllCountriesEnbled: false,
				enabledCountries: ["BE", "DK", "UK"]
			)
		)

		let expectation = self.expectation(description: "did receive model update")
		model.$euTracingSettings
			.dropFirst()
			.prefix(1)
			.sink { settings in
				XCTAssertFalse(settings.isAllCountriesEnbled)
				XCTAssertFalse(settings.enabledCountries.contains("UK"))
				expectation.fulfill()
			}
			.store(in: &subscriptions)

		model.countryModels.first { $0.country.id == "UK" }?.isOn = false
		waitForExpectations(timeout: .short)
	}

	func testAllCountriesOn() {
		let model = EUSettingsViewModel(
			countries: testCountries,
			euTracingSettings: EUTracingSettings(
				isAllCountriesEnbled: false,
				enabledCountries: ["BE", "DK", "UK"]
			)
		)

		XCTAssertFalse(model.euTracingSettings.isAllCountriesEnbled)

		let expectation = self.expectation(description: "did receive model update")
		model.$euTracingSettings
			.dropFirst()
			.prefix(1)
			.sink { settings in
				XCTAssert(settings.isAllCountriesEnbled)
				XCTAssert(settings.enabledCountries.contains("CZ"))
				expectation.fulfill()
			}
			.store(in: &subscriptions)

		model.countryModels.first { $0.country.id == "CZ" }?.isOn = true
		waitForExpectations(timeout: .short)
	}

	func testAllCountriesOff() {
		let model = EUSettingsViewModel(
			countries: testCountries,
			euTracingSettings: EUTracingSettings(
				isAllCountriesEnbled: true,
				enabledCountries: testCountries.map { $0.id }
			)
		)

		XCTAssert(model.euTracingSettings.isAllCountriesEnbled)

		let expectation = self.expectation(description: "did receive model update")
		model.$euTracingSettings
			.dropFirst()
			.prefix(1)
			.sink { settings in
				XCTAssertFalse(settings.isAllCountriesEnbled)
				XCTAssertFalse(settings.enabledCountries.contains("CZ"))
				expectation.fulfill()
			}
			.store(in: &subscriptions)

		model.countryModels.first { $0.country.id == "CZ" }?.isOn = false
		waitForExpectations(timeout: .short)
	}

	// It was agreed that the EUTracingSettings should _not_ contain the default country.
	func testEuTracingSettingsDoNotContainDefaultCountry() {
		let model = EUSettingsViewModel(
			countries: testCountries,
			euTracingSettings: EUTracingSettings(
				isAllCountriesEnbled: true,
				enabledCountries: testCountries.map { $0.id }
			)
		)

		let expectation = self.expectation(description: "did receive model update")
		model.$euTracingSettings
			.prefix(1)
			.sink { settings in
				XCTAssertFalse(settings.enabledCountries.contains(Country.defaultCountry().id))
				expectation.fulfill()
			}
			.store(in: &subscriptions)

		waitForExpectations(timeout: .short)
	}
}
