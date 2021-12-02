//
// 🦠 Corona-Warn-App
//

struct SubmissionTANModel: Codable {
	let submissionTAN: String
	
	enum CodingKeys: String, CodingKey {
		case submissionTAN = "tan"
	}
}
