//
// 🦠 Corona-Warn-App
//

struct RegistrationReceiveModel: Codable {
	let submissionTAN: String
	
	enum CodingKeys: String, CodingKey {
		case submissionTAN = "tan"
	}
}
