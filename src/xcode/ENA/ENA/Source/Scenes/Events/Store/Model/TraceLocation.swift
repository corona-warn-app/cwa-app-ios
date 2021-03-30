////
// 🦠 Corona-Warn-App
//

// This implementation is based on the following technical specification.
// For more details please see: https://github.com/corona-warn-app/cwa-app-tech-spec/blob/e87ef2851c91141573d5714fd24485219280543e/docs/spec/event-registration-client.md

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
	let cnPublicKey: Data

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

extension TraceLocation {
	
	// MARK: - Init
	
	init?(qrCodeString: String) {
		
		guard let data = qrCodeString.base32DecodedData else {
			Log.error("Couldn't serialize the data")
			return nil
		}
		Log.debug("Data found: \(String(describing: data))")


		do {
			// creates a fake event for the moment
			let qRCodePayload = try SAP_Internal_Pt_QRCodePayload(serializedData: data)
			let traceLocation = qRCodePayload.locationData
			let eventInformation = try SAP_Internal_Pt_CWALocationData(serializedData: qRCodePayload.vendorData)
			
			let startDate = traceLocation.startTimestamp == 0 ? nil : Date(timeIntervalSince1970: TimeInterval(traceLocation.startTimestamp))
			let endDate = traceLocation.startTimestamp == 0 ? nil : Date(timeIntervalSince1970: TimeInterval(traceLocation.endTimestamp))
			
			guard let id = qRCodePayload.id else {
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
				defaultCheckInLengthInMinutes: Int(eventInformation.defaultCheckInLengthInMinutes),
				cryptographicSeed: qRCodePayload.crowdNotifierData.cryptographicSeed,
				cnPublicKey: qRCodePayload.crowdNotifierData.publicKey
			)
		} catch {
			Log.error(error.localizedDescription, log: .checkin, error: error)
			return nil
		}
	}
}
