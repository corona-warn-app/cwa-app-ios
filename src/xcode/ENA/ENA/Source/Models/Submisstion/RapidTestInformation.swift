////
// 🦠 Corona-Warn-App
//

import Foundation

struct RapidTestInformation: Codable {
	
	// MARK: - Init
	
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
			self = try JSONDecoder().decode(RapidTestInformation.self, from: jsonData)
		} catch {
			Log.debug("Failed to read / parse district json", log: .ppac)
			return nil
		}
	}
	
	func verify() {
		
	}
	
	// MARK: - Internal
	
	let guid: String
	let timestamp: Int
	let firstName: String?
	let lastName: String?
	let dateOfBirth: String?
	
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
	
	private enum CodingKeys: String, CodingKey {
		case guid, timestamp, firstName = "fn", lastName = "ln", dateOfBirth = "dob"
	}
}
