////
// 🦠 Corona-Warn-App
//

import Foundation

struct RapidTestInformation: Codable {
	
	// MARK: - Init
	
	init?(payload: String) {
		guard let jsonData = Data(base64URLEncoded: payload) else {
			return nil
		}
		do {
			self = try JSONDecoder().decode(RapidTestInformation.self, from: jsonData)
		} catch {
			Log.debug("Failed to read / parse district json", log: .ppac)
			return nil
		}
	}
	
	// MARK: - Internal
	
	let guid: String
	let timestamp: Int
	let firstName: String
	let lastName: String
	let dateOfBirth: String
	
	var fullName: String {
		return firstName + " " + lastName
	}
	var pointOfCareConsentDate: Date {
		return Date(timeIntervalSince1970: TimeInterval(timestamp))
	}
	// MARK: - Private
	
	private enum CodingKeys: String, CodingKey {
		case guid, timestamp, firstName = "fn", lastName = "ln", dateOfBirth = "dob"
	}
}
