////
// 🦠 Corona-Warn-App
//

struct TraceLocation {

	let id: Data
	let version: Int
	let type: TraceLocationType
	let description: String
	let address: String
	let startDate: Date?
	let endDate: Date?
	let defaultCheckInLengthInMinutes: Int?
	let cryptographicSeed: Data
	let cnMainPublicKey: Data

	var isActive: Bool {
		guard let endDate = endDate else {
			return true
		}

		return Date() < endDate
	}
	
	var qrCodeURL: String {
		return "ToDo"
//		let encodedByteRepresentation = id.base32EncodedString
//		return String(format: "https://e.coronawarn.app/c1/%@", id).uppercased()
	}

}
