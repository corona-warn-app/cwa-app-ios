////
// 🦠 Corona-Warn-App
//

// This implementation is based on the following technical specification.
// For more details please see: https://github.com/corona-warn-app/cwa-app-tech-spec/blob/e87ef2851c91141573d5714fd24485219280543e/docs/spec/event-registration-client.md

struct TraceLocation {

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
	
	var isActive: Bool {
		guard let endDate = endDate else {
			return true
		}

		return Date() < endDate
	}

	var idHash: Data? {
		return id.sha256()
	}
	
	var qrCodeURL: String? {
		guard let base32EncodedString = qrCodePayloadData?.base32EncodedString.trimmingCharacters(in: ["="]) else {
			return nil
		}

		return String(format: "https://e.coronawarn.app/c1/%@", base32EncodedString).uppercased()
	}

	var suggestedCheckoutLength: Int {
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
		let remainderMinutes = duration % durationStep
		if remainderMinutes != 0 {
			return duration + (durationStep - remainderMinutes)
		} else {
			return duration
		}
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

}

extension TraceLocation {
	
	// MARK: - Init
	
	init?(qrCodeString: String, encoding: EncodingType) {
		
		let decodedData: Data
		switch encoding {
		case .base32:
			guard let data = qrCodeString.base32DecodedData else {
				Log.error("Couldn't serialize the data using base32")
				return nil
			}
			decodedData = data
		case .base64:
			guard let data = Data(base64Encoded: qrCodeString) else {
				Log.error("Couldn't serialize the data using base64")
				return nil
			}
			decodedData = data
		case .unspecified:
			guard let data = qrCodeString.base32DecodedData else {
				Log.error("Got unspecified encoding type, will try to encode using base32")
				return nil
			}
			decodedData = data
		}
	
		Log.debug("Data found: \(String(describing: decodedData))")


		do {
			// creates a fake event for the moment
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
				description: traceLocation.description_p,
				address: traceLocation.address,
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
