//
// 🦠 Corona-Warn-App
//

struct RegistrationTokenReceiveModel: Codable {
	let submissionTAN: String
	
	enum CodingKeys: String, CodingKey {
		case submissionTAN = "tan"
	}
}
