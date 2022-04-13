////
// 🦠 Corona-Warn-App
//

import Foundation

struct AntigenTestProfile: Codable {

	// MARK: - Init

	init(
		id: UUID = UUID(),
		firstName: String? = nil,
		lastName: String? = nil,
		dateOfBirth: Date? = nil,
		addressLine: String? = nil,
		zipCode: String? = nil,
		city: String? = nil,
		phoneNumber: String? = nil,
		email: String? = nil
	) {
		self.id = id
		self.firstName = firstName
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
		try container.encode(id, forKey: .id)
		try container.encodeIfPresent(firstName, forKey: .firstName)
		try container.encodeIfPresent(lastName, forKey: .lastName)
		if let dateOfBirth = dateOfBirth {
			try? container.encodeIfPresent(ISO8601DateFormatter.justUTCDateFormatter.string(from: dateOfBirth), forKey: .dateOfBirth)
		}
		try container.encodeIfPresent(addressLine, forKey: .addressLine)
		try container.encodeIfPresent(zipCode, forKey: .zipCode)
		try container.encodeIfPresent(city, forKey: .city)
		try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
		try container.encodeIfPresent(email, forKey: .email)
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		if let profileId = try? container.decode(UUID.self, forKey: .id) {
			id = profileId
		} else {
			id = UUID()
		}
		firstName = try? container.decode(String.self, forKey: .firstName)
		lastName = try? container.decode(String.self, forKey: .lastName)
		if let validFromString = try? container.decode(String.self, forKey: .dateOfBirth) {
			dateOfBirth = ISO8601DateFormatter.justUTCDateFormatter.date(from: validFromString)
		} else {
			dateOfBirth = nil
		}
		addressLine = try? container.decode(String.self, forKey: .addressLine)
		zipCode = try? container.decode(String.self, forKey: .zipCode)
		city = try? container.decode(String.self, forKey: .city)
		phoneNumber = try? container.decode(String.self, forKey: .phoneNumber)
		email = try? container.decode(String.self, forKey: .email)
	}

	enum CodingKeys: String, CodingKey, CaseIterable {
		case id
		case firstName
		case lastName
		case dateOfBirth
		case addressLine
		case zipCode
		case city
		case phoneNumber
		case email
	}

	// MARK: - Internal

	var id: UUID
	var firstName: String?
	var lastName: String?
	var dateOfBirth: Date?
	var addressLine: String?
	var zipCode: String?
	var city: String?
	var phoneNumber: String?
	var email: String?

}
