////
// 🦠 Corona-Warn-App
//

// This implementation is based on the following technical specification.
// For more details please see: https://github.com/corona-warn-app/cwa-app-tech-spec/blob/e87ef2851c91141573d5714fd24485219280543e/docs/spec/event-registration-client.md

import Foundation

struct TraceLocation: Equatable {

	// MARK: - Internal

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

	var idHash: Data? {
		return id.sha256()
	}
	
	var qrCodeURL: String? {
		guard let base64URLEncodedString = qrCodePayloadData?.base64URLEncodedString() else {
			return nil
		}

		return String(format: "https://e.coronawarn.app?v=1#%@", base64URLEncodedString)
	}

	/// Duration from `defaultCheckInLengthInMinutes`, if not set the interval from `startDate` to `endDate`, if not set 15 minutes.
	/// Rounded to the next 15 minute interval, capped at 23:45h
	var suggestedCheckoutLengthInMinutes: Int {
		let fallback = 15

		var duration: Int
		if let defaultDuration = defaultCheckInLengthInMinutes, defaultDuration > 0 {
			duration = defaultDuration
		} else if let startDate = startDate, startDate.timeIntervalSince1970 > 0,
				  let endDate = endDate, endDate.timeIntervalSince1970 > 0 {
			let eventDuration = Calendar.current.dateComponents(
				[.minute],
				from: startDate,
				// The event duration should be atleast 15 minutes
				to: endDate.addingTimeInterval(15 * 60)
			).minute

			duration = eventDuration ?? fallback
		} else {
			duration = fallback
		}

		return roundedTo15Minutes(duration)
	}

	/// Duration calculated from the interval between `startDate` and `endDate`, if not set `defaultCheckInLengthInMinutes`, if not set 120 minutes.
	/// Rounded to the next 15 minute interval, capped at 23:45h
	var suggestedOnBehalfWarningDurationInMinutes: Int {
		let fallback = 120

		var duration: Int
		if let startDate = startDate, startDate.timeIntervalSince1970 > 0,
				  let endDate = endDate, endDate.timeIntervalSince1970 > 0 {
			let eventDuration = Calendar.current.dateComponents(
				[.minute],
				from: startDate,
				to: endDate
			).minute

			duration = eventDuration ?? fallback
		} else if let defaultDuration = defaultCheckInLengthInMinutes, defaultDuration > 0 {
			duration = defaultDuration
		} else {
			duration = fallback
		}

		return roundedTo15Minutes(duration)
	}

	// MARK: - Private

	private var qrCodePayloadData: Data? {
		let cwaLocationData = SAP_Internal_Pt_CWALocationData.with {
			$0.version = 1
			$0.type = SAP_Internal_Pt_TraceLocationType(rawValue: type.rawValue) ?? .locationTypeUnspecified
			$0.defaultCheckInLengthInMinutes = defaultCheckInLengthInMinutes.map { UInt32($0) } ?? 0
		}

		guard let cwaLocationSerializedData = try? cwaLocationData.serializedData() else {
			return nil
		}

		return try? SAP_Internal_Pt_QRCodePayload.with {
			$0.version = 1

			$0.locationData.version = UInt32(version)
			$0.locationData.description_p = description
			$0.locationData.address = address
			$0.locationData.startTimestamp = startDate.map { UInt64($0.timeIntervalSince1970) } ?? 0
			$0.locationData.endTimestamp = endDate.map { UInt64($0.timeIntervalSince1970) } ?? 0

			$0.vendorData = cwaLocationSerializedData

			$0.crowdNotifierData.version = 1
			$0.crowdNotifierData.publicKey = cnPublicKey
			$0.crowdNotifierData.cryptographicSeed = cryptographicSeed
		}.serializedData()
	}

	private func roundedTo15Minutes(_ duration: Int) -> Int {
		var duration = duration

		// rounding up to 15
		let durationStep = 15
		let remainderMinutes = duration % durationStep
		if remainderMinutes != 0 {
			duration += (durationStep - remainderMinutes)
		}

		let maxDurationInMinutes = (23 * 60) + 45
		return min(duration, maxDurationInMinutes)
	}

}

extension TraceLocation {
	
	// MARK: - Init
	
	/// Expects the String to be Base64URL encoded
	init?(qrCodeString: String) {
		
		guard let decodedData = Data(base64URLEncoded: qrCodeString) else {
			Log.error("Couldn't serialize the data using base64URL")
			return nil
		}
		
		Log.debug("Data found: \(private: String(describing: decodedData), public: "Decoded qrCode")")
		
		
		do {
			let qrCodePayload = try SAP_Internal_Pt_QRCodePayload(serializedData: decodedData)
			let traceLocation = qrCodePayload.locationData
			let eventInformation = try SAP_Internal_Pt_CWALocationData(serializedData: qrCodePayload.vendorData)
			
			let startDate = traceLocation.startTimestamp == 0 ? nil : Date(timeIntervalSince1970: TimeInterval(traceLocation.startTimestamp))
			let endDate = traceLocation.startTimestamp == 0 ? nil : Date(timeIntervalSince1970: TimeInterval(traceLocation.endTimestamp))
			let defaultCheckInLengthInMinutes = eventInformation.defaultCheckInLengthInMinutes == 0 ? nil : Int(eventInformation.defaultCheckInLengthInMinutes)

			guard let id = qrCodePayload.id else {
				Log.error("Error in creating the qRCodePayload id", log: .checkin)
				return nil
			}
			self = TraceLocation(
				id: id,
				version: Int(traceLocation.version),
				type: TraceLocationType(traceLocationTypeProtobuf: eventInformation.type),
				description: traceLocation.description_p.cleanedFromSpecialCharacters(),
				address: traceLocation.address.cleanedFromSpecialCharacters(),
				startDate: startDate,
				endDate: endDate,
				defaultCheckInLengthInMinutes: defaultCheckInLengthInMinutes,
				cryptographicSeed: qrCodePayload.crowdNotifierData.cryptographicSeed,
				cnPublicKey: qrCodePayload.crowdNotifierData.publicKey
			)
		} catch {
			Log.error(error.localizedDescription, log: .checkin, error: error)
			return nil
		}
	}
}

private extension String {
	
	func cleanedFromSpecialCharacters() -> String {
		return self
			.replacingOccurrences(of: "\0", with: "", options: .literal, range: nil) // remove Null character \0
			.replacingOccurrences(of: "\u{0C}", with: "", options: .literal, range: nil) // remove FormFeed character \u{0C}
			.replacingOccurrences(of: "\t", with: "", options: .literal, range: nil) // remove Tab character \t
		
	}
}
