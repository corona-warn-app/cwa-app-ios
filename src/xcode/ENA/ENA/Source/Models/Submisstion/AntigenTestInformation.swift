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
		dateOfBirth: Date?,
		testID: String?,
		cryptographicSalt: String?
	) {
		self.hash = hash
		self.timestamp = timestamp
		self.firstName = firstName
		self.lastName = lastName
		self.dateOfBirth = dateOfBirth
		self.testID = testID
		self.cryptographicSalt = cryptographicSalt
		guard let dateOfBirth = dateOfBirth else {
			self.dateOfBirthString = nil
			return
		}
		self.dateOfBirthString = AntigenTestInformation.isoFormatter.string(from: dateOfBirth)
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
			let decodedObject = try JSONDecoder().decode(AntigenTestInformation.self, from: jsonData)
			
			self.hash = decodedObject.hash
			self.timestamp = decodedObject.timestamp
			self.firstName = decodedObject.firstName?.isEmpty ?? true ? nil : decodedObject.firstName
			self.lastName = decodedObject.lastName?.isEmpty ?? true ? nil : decodedObject.lastName
			self.testID = decodedObject.testID?.isEmpty ?? true ? nil : decodedObject.testID
			self.cryptographicSalt = decodedObject.cryptographicSalt?.isEmpty ?? true ? nil : decodedObject.cryptographicSalt
			self.dateOfBirthString = decodedObject.dateOfBirthString?.isEmpty ?? true ? nil : decodedObject.dateOfBirthString
			self.dateOfBirth = AntigenTestInformation.isoFormatter.date(from: decodedObject.dateOfBirthString ?? "")
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
		case dateOfBirthString = "dob"
		case testID = "testid"
		case cryptographicSalt = "salt"
	}
	
	// MARK: - Internal
	
	let hash: String
	let timestamp: Int
	let firstName: String?
	let lastName: String?
	let testID: String?
	let cryptographicSalt: String?
	let dateOfBirthString: String?
	var dateOfBirth: Date?
	
	var fullName: String? {
		guard let first = firstName, let last = lastName else {
			return nil
		}
		return first + " " + last
	}
	var pointOfCareConsentDate: Date {
		return Date(timeIntervalSince1970: TimeInterval(timestamp))
	}
	
	// MARK: - Private
	
	static let isoFormatter: ISO8601DateFormatter = {
		let isoFormatter = ISO8601DateFormatter()
		isoFormatter.formatOptions = [.withFullDate]
		isoFormatter.timeZone = TimeZone.utcTimeZone
		return isoFormatter
	}()
}
