////
// 🦠 Corona-Warn-App
//

import Foundation

struct RapidTestProfile: Codable {

	// MARK: - Protocol Codable

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(forename, forKey: .forename)
		try container.encode(lastName, forKey: .lastName)
		if let dateOfBirth = dateOfBirth {
			try container.encode(ISO8601DateFormatter.justDate.string(from: dateOfBirth), forKey: .dateOfBirth)
		}
		try container.encode(addressLine, forKey: .addressLine)
		try container.encode(zipCode, forKey: .zipCode)
		try container.encode(city, forKey: .city)
		try container.encode(phoneNumber, forKey: .phoneNumber)
		try container.encode(email, forKey: .email)
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		forename = try? container.decode(String.self, forKey: .forename)
		lastName = try? container.decode(String.self, forKey: .lastName)
		if let validFromString = try? container.decode(String.self, forKey: .dateOfBirth) {
			dateOfBirth = ISO8601DateFormatter.justDate.date(from: validFromString)
		} else {
			dateOfBirth = nil
		}
		addressLine = try? container.decode(String.self, forKey: .addressLine)
		zipCode = try? container.decode(String.self, forKey: .zipCode)
		city = try? container.decode(String.self, forKey: .city)
		phoneNumber = try? container.decode(String.self, forKey: .phoneNumber)
		email = try? container.decode(String.self, forKey: .email)
	}

	enum CodingKeys: String, CodingKey {
		case forename
		case lastName
		case dateOfBirth
		case addressLine
		case zipCode
		case city
		case phoneNumber
		case email
	}


	// MARK: - Internal

	let forename: String?
	let lastName: String?
	let dateOfBirth: Date?
	let addressLine: String?
	let zipCode: String?
	let city: String?
	let phoneNumber: String?
	let email: String?

}
