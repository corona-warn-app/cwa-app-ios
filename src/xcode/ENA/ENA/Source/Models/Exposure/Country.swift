//
// 🦠 Corona-Warn-App
//

import UIKit


/// A simple data countainer representing a country or political region.
struct Country: Equatable, Codable {

	typealias ID = String

	/// The country identifier. Equals the initializing country code.
	let id: ID

	/// The localized name of the country using the current locale.
	let localizedName: String

	/// The flag of the current country, if present.
	var flag: UIImage? {
		UIImage(named: "flag.\(id.lowercased())")
	}

	/// Initialize a country with a given. If no valid `countryCode` is given the initalizer returns `nil`.
	///
	/// - Parameter countryCode: An [ISO 3166 (Alpha-2)](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Officially_assigned_code_elements) country two-digit code. Examples: "DE", "FR"
	init?(countryCode: ID) {
		// Check if this is a valid country
		guard let name = Locale.current.regionName(forCountryCode: countryCode) else { return nil }

		id = countryCode
		localizedName = name
	}

	static func defaultCountry() -> Country {
		// swiftlint:disable:next force_unwrapping
		return Country(countryCode: "DE")!
	}

}

extension Locale {

	func regionName(forCountryCode code: String) -> String? {
		var identifier: String

		// quick solution for the EU scenario
		switch code.lowercased() {
		case "el":
			identifier = "gr"
		case "no":
			identifier = "nb_NO"
		// There was a decision not to use the 2 letter code "EU", but instead "EUR".
		// Please see this story for more informations: https://jira.itc.sap.com/browse/EXPOSUREBACK-151
		case "eur":
			identifier = "eu"
		default:
			identifier = code
		}

		let target = Locale(identifier: identifier)
		
		// catch cases where multiple languages per region might appear, e.g. Norway
		guard let regionCode = target.identifier.components(separatedBy: "_").last else {
			return nil
		}

		return localizedString(forRegionCode: regionCode)
	}

}

extension Array where Element == Country {
	var sortedByLocalizedName: [Country] {
		self.sorted { $0.localizedName.localizedCompare($1.localizedName) == .orderedAscending }
	}
}
