//
// 🦠 Corona-Warn-App
//

struct TeleTanReceiveModel: Codable {
	let submissionTAN: String
	
	enum CodingKeys: String, CodingKey {
		case submissionTAN = "tan"
	}
}
