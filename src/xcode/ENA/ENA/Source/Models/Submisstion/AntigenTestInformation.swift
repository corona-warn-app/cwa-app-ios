////
// 🦠 Corona-Warn-App
//

import Foundation

struct AntigenTestInformation: Codable, Equatable {
	
	// MARK: - Init

	init(
		hash: String,
		timestamp: Int,
		firstName: String?,
		lastName: String?,
		dateOfBirth: Date?
	) {
		self.hash = hash
		self.timestamp = timestamp
		self.firstName = firstName
		self.lastName = lastName
		self.dateOfBirth = dateOfBirth
	}

	init?(payload: String) {

		let jsonData: Data
		if payload.isBase64Encoded {
			guard let parsedData = Data(base64Encoded: payload) else {
				return nil
			}
			jsonData = parsedData
		} else {
			guard let parsedData = Data(base64URLEncoded: payload) else {
				return nil
			}
			jsonData = parsedData
		}
		do {
			let jsonDecoder = JSONDecoder()
			jsonDecoder.dateDecodingStrategy = .custom({ decoder -> Date in
				let container = try decoder.singleValueContainer()
				let stringDate = try container.decode(String.self)
				guard let date = AntigenTestInformation.isoFormatter.date(from: stringDate) else {
					throw DecodingError.dataCorruptedError(in: container, debugDescription: "failed to decode date \(stringDate)")
				}
				return date
			})

			self = try jsonDecoder.decode(AntigenTestInformation.self, from: jsonData)
		} catch {
			Log.debug("Failed to read / parse district json", log: .ppac)
			return nil
		}
	}

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case hash
		case timestamp
		case firstName = "fn"
		case lastName = "ln"
		case dateOfBirth = "dob"
	}
		
	// MARK: - Internal
	
	let hash: String
	let timestamp: Int
	let firstName: String?
	let lastName: String?
	let dateOfBirth: Date?
	
	var fullName: String? {
		guard let first = firstName, let last = lastName else {
			return nil
		}
		return first + " " + last
	}
	var pointOfCareConsentDate: Date {
		return Date(timeIntervalSince1970: TimeInterval(timestamp))
	}

	var dateOfBirthString: String? {
		guard let dateOfBirth = dateOfBirth else {
			return nil
		}
		return AntigenTestInformation.isoFormatter.string(from: dateOfBirth)
	}
	var hashOfTheHash: String {
		guard let hashData = hash.data(using: .utf8) else {
			Log.error("hash string couldn't be parsed to a data object", log: .qrCode)
			return ""
		}
		return hashData.sha256String()
	}
		
	// MARK: - Private

	static let isoFormatter: ISO8601DateFormatter = {
		let isoFormatter = ISO8601DateFormatter()
		isoFormatter.formatOptions = [.withFullDate]
		isoFormatter.timeZone = TimeZone.current
		return isoFormatter
	}()
}
