////
// 🦠 Corona-Warn-App
//

// This implementation is based on the following technical specification.
// For more details please see: https://github.com/corona-warn-app/cwa-app-tech-spec/blob/e87ef2851c91141573d5714fd24485219280543e/docs/spec/event-registration-client.md

struct TraceLocation {

	// MARK: - Internal
	
	/// The ID of the event. Note that the ID is generated by the CWA server. It is stored as base64-encoded string of the guid attribute of Protocol Buffer message Event.
	let id: Data
	let version: Int
	let type: TraceLocationType
	let description: String
	let address: String
	let startDate: Date?
	let endDate: Date?
	let defaultCheckInLengthInMinutes: Int?
	let cryptographicSeed: Data
	let cnPublicKey: Data

	var initialTimeForCheckout: Int {
		let duration: Int
		if let defaultDuration = defaultCheckInLengthInMinutes {
			duration = defaultDuration
		} else {
			let eventDuration = Calendar.current.dateComponents(
				[.minute],
				from: startDate ?? Date(),
				to: endDate ?? Date()
			).minute
			// the 0 should not be possible since we expect either the defaultCheckInLengthInMinutes or the start and end dates to be available always
			duration = eventDuration ?? 0
		}
		// rounding up to 15
		let durationStep = 15
		let reminderMinutes = duration % durationStep
		if reminderMinutes != 0 {
			return duration + (durationStep - reminderMinutes)
		} else {
			return duration
		}
	}
	
	var isActive: Bool {
		guard let endDate = endDate else {
			return true
		}

		return Date() < endDate
	}
	
	var guidHash: Data? {
		return id.data(using: .utf8)?.sha256()
	}
	
	var qrCodeURL: String {
		return "ToDo"
//		let encodedByteRepresentation = id.base32EncodedString
//		return String(format: "https://e.coronawarn.app/c1/%@", id).uppercased()
	}
}
