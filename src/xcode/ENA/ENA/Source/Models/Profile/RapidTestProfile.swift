////
// 🦠 Corona-Warn-App
//

import Foundation

struct RapidTestProfile: Codable {

	// MARK: - Init

	init(
		forename: String? = nil,
		lastName: String? = nil,
		dateOfBirth: Date? = nil,
		addressLine: String? = nil,
		zipCode: String? = nil,
		city: String? = nil,
		phoneNumber: String? = nil,
		email: String? = nil
	) {
		self.forename = forename
		self.lastName = lastName
		self.dateOfBirth = dateOfBirth
		self.addressLine = addressLine
		self.zipCode = zipCode
		self.city = city
		self.phoneNumber = phoneNumber
		self.email = email
	}

	// MARK: - Protocol Codable

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(lastName, forKey: .lastName)
		if let dateOfBirth = dateOfBirth {
			try? container.encodeIfPresent(ISO8601DateFormatter.justDate.string(from: dateOfBirth), forKey: .dateOfBirth)
		}
		try container.encodeIfPresent(addressLine, forKey: .addressLine)
		try container.encodeIfPresent(zipCode, forKey: .zipCode)
		try container.encodeIfPresent(city, forKey: .city)
		try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
		try container.encodeIfPresent(email, forKey: .email)
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
