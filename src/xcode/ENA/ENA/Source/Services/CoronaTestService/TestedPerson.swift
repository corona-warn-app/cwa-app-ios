////
// 🦠 Corona-Warn-App
//

import Foundation

struct TestedPerson: Codable, Equatable, Hashable {

	// MARK: - Internal

	let firstName: String?
	let lastName: String?
	let dateOfBirth: String?

	var fullName: String? {
		let formatter = PersonNameComponentsFormatter()
		formatter.style = .long

		var nameComponents = PersonNameComponents()
		nameComponents.givenName = firstName
		nameComponents.familyName = lastName

		return formatter.string(from: nameComponents)
	}

	var formattedDateOfBirth: String? {
		guard let dateOfBirth = dateOfBirth else {
			return nil
		}

		let inputFormatter = ISO8601DateFormatter.justLocalDateFormatter
		guard let date = inputFormatter.date(from: dateOfBirth) else {
			return nil
		}

		return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
	}

}
