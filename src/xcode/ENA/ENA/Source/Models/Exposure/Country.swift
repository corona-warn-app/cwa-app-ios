//
// 🦠 Corona-Warn-App
//

import UIKit


/// A simple data container representing a country or political region.
struct Country: Equatable, Codable {

	// MARK: - Init
	#if !RELEASE
	init(
		id: Country.ID,
		localizedName: String
	) {
		self.id = id
		self.localizedName = localizedName
	}
	#endif

	/// Initialize a country with a given `countryCode`. If no valid `countryCode` is given the initializer returns `nil`.
	///
	/// - Parameter countryCode: An [ISO 3166 (Alpha-2)](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Officially_assigned_code_elements) country two-digit code. Examples: "DE", "FR"
	init?(countryCode: ID) {
		// Check if this is a valid country
		guard let name = Locale.current.regionName(forCountryCode: countryCode) else { return nil }

		id = countryCode
		localizedName = name
	}

	/// Initialize a country with a given `countryCode`. If `countryCode` cannot be localized, the localizedName will contain the `countryCode`.
	///
	/// - Parameter countryCode: An [ISO 3166 (Alpha-2)](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Officially_assigned_code_elements) country two-digit code. Examples: "DE", "FR"
	init(withCountryCodeFallback countryCode: ID) {
		id = countryCode
		localizedName = Locale.current.regionName(forCountryCode: countryCode) ?? countryCode
	}

	// MARK: - Protocol Equatable

	static func == (lhs: Country, rhs: Country) -> Bool {
		return lhs.id == rhs.id
	}

	// MARK: - Internal

	typealias ID = String

	/// The country identifier. Equals the initializing country code.
	let id: ID

	/// The localized name of the country using the current locale.
	let localizedName: String

	/// The flag of the current country, if present.
	var flag: UIImage? {
		UIImage(named: "flag.\(id.lowercased())")
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
		// quick solution for the Chinese(Traditional, Taiwan)
		case "tw":
			identifier = "zh_tw"
		// There was a decision not to use the 2 letter code "EU", but instead "EUR".
		// Please see this story for more information: https://jira.itc.sap.com/browse/EXPOSUREBACK-151
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
