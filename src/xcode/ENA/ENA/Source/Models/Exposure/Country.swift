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

import UIKit


/// A simple data countainer representing a country or political region.
struct Country: Equatable {

	/// The country identifier. Equals the initializing country code.
	let id: String

	/// The localized name of the country using the current locale.
	let localizedName: String

	/// The flag of the current country, if present.
	let flag: UIImage?

	/// Initialize a country with a given. If no valid `countryCode` is given the initalizer returns `nil`.
	///
	/// - Parameter countryCode: An [ISO 3166 (Alpha-2)](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Officially_assigned_code_elements) country two-digit code. Examples: "DE", "FR"
	init?(countryCode: String) {
		// Check if this is a valid country
		guard let name = Locale.current.localizedString(forRegionCode: countryCode) else { return nil }

		id = countryCode
		localizedName = name
		// swiftlint:disable:next force_unwrapping
		flag = UIImage(named: "flag.\(countryCode.lowercased())")
	}
}
