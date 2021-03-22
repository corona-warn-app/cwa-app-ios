////
// 🦠 Corona-Warn-App
//

enum TraceLocationType: Int {
	case type1
	case type2
	case type3
}

struct TraceLocation {

	/// The ID of the event. Note that the ID is generated by the CWA server. It is stored as base64-encoded string of the guid attribute of Protocol Buffer message Event.
	let guid: String
	let version: Int
	let type: TraceLocationType
	let description: String
	let address: String
	let startDate: Date?
	let endDate: Date?
	let defaultCheckInLengthInMinutes: Int?
	/// The signature of the event (provided by the CWA server). It is stored as a base64-encoded string of the signature attribute of Protocol Buffer message SignedEvent.
	let signature: String

	var isActive: Bool {
		guard let endDate = endDate else {
			return true
		}

		return Date() < endDate
	}

}
