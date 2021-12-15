//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class CheckinQRCodeParser: QRCodeParsable {
	
	// MARK: - Init

	init(
		appConfigurationProvider: AppConfigurationProviding
	) {
		self.appConfigurationProvider = appConfigurationProvider
	}

	// MARK: - Protocol QRCodeParsable

	func parse(
		qrCode: String,
		completion: @escaping (Result<QRCodeResult, QRCodeParserError>) -> Void
	) {
		Log.info("Parse checkin.")

		#if DEBUG
		if isUITesting {
			let traceLocation = TraceLocation(
				id: UUID().uuidString.data(using: .utf8) ?? Data(),
				version: 0,
				type: .locationTypePermanentFoodService,
				description: "Bistro & Café am Neuen Markt",
				address: "Hamburg, Schulstraße 4",
				startDate: nil,
				endDate: nil,
				defaultCheckInLengthInMinutes: 90,
				cryptographicSeed: Data(),
				cnPublicKey: Data()
			)
			completion(.success(.traceLocation(traceLocation)))
			return
		}
		#endif

		verifyQrCode(
			qrCodeString: qrCode,
			onSuccess: { traceLocation in
				Log.info("Successfuly parsed checkin.")
				completion(.success(.traceLocation(traceLocation)))
			},
			onError: { error in
				Log.info("Failed parsing checkin with error: \(error)")
				completion(.failure(.checkinQrError(error)))
			}
		)
	}

	// MARK: - Internal

	func verifyQrCode(
		qrCodeString url: String,
		onSuccess: @escaping((TraceLocation) -> Void),
		onError: @escaping((CheckinQRScannerError) -> Void)
	) {
		let appConfig = appConfigurationProvider.currentAppConfig.value
		// 1-Validate URL
		var match: NSTextCheckingResult?
		let descriptor = appConfig.presenceTracingParameters.qrCodeDescriptors.first {
			do {
				let regex = try NSRegularExpression(pattern: $0.regexPattern, options: [.caseInsensitive])
				match = regex.firstMatch(in: url, range: .init(location: 0, length: url.count))
				return match != nil
			} catch {
				Log.error(error.localizedDescription, log: .checkin)
				return false
			}
		}

		// Extract ENCODED_PAYLOAD
		// for some reason we get an extra match at index 0 which is the entire URL so we need to add an offset of 1 to each index after that to get the correct corresponding parts
		guard let unWrappedMatch = match, let qrDescriptor = descriptor else {
			Log.error("the QRCode matched none of the regular expressions", log: .checkin)
			onError(CheckinQRScannerError.codeNotFound)
			return
		}
		let payLoadIndex = qrDescriptor.encodedPayloadGroupIndex
		guard payLoadIndex < unWrappedMatch.numberOfRanges,
			  let payLoadRange = Range(unWrappedMatch.range(at: Int(payLoadIndex) + 1), in: url) else {
				  Log.error("payLoadIndex is out of bounds, invalid payload", log: .checkin)
				  onError(CheckinQRScannerError.invalidPayload)
				  return
			  }

		let payLoad = url[payLoadRange]
		guard let traceLocation = TraceLocation(qrCodeString: String(payLoad)) else {
			Log.error("error decoding the Payload, invalid Vendor data", log: .checkin)
			onError(CheckinQRScannerError.invalidVendorData)
			return
		}
		validateTraceLocationInformation(traceLocation: traceLocation, onSuccess: onSuccess, onError: onError)
	}

	func validateTraceLocationInformation(
		traceLocation: TraceLocation,
		onSuccess: @escaping((TraceLocation) -> Void),
		onError: @escaping((CheckinQRScannerError) -> Void)
	) {
		guard !traceLocation.description.isEmpty,
			  traceLocation.description.count <= kMaxDescriptionLength,
			  !traceLocation.description.contains("\n"),
			  !traceLocation.description.contains("\r")
		else {
			Log.error("TraceLocation description cannot be empty, >100, or contain line break!", log: .checkin)
			onError(CheckinQRScannerError.invalidDescription)
			return
		}
		guard !traceLocation.address.isEmpty,
			  traceLocation.address.count <= kMaxAddressLength,
			  !traceLocation.address.contains("\n"),
			  !traceLocation.address.contains("\r")
		else {
			Log.error("TraceLocation address cannot be empty, >100, or contain line break!", log: .checkin)
			onError(CheckinQRScannerError.invalidAddress)
			return
		}
		guard traceLocation.cryptographicSeed.count == 16 else {
			Log.error("TraceLocation cryptographicSeed must be 16 bytes!", log: .checkin)
			onError(CheckinQRScannerError.invalidCryptoSeed)
			return
		}

		let startTimeStamp = traceLocation.startDate?.timeIntervalSince1970 ?? 0
		let endTimeStamp = traceLocation.endDate?.timeIntervalSince1970 ?? 0
		let bothTimeStampsAreZero = (startTimeStamp == 0 && endTimeStamp == 0)
		let startTimeIsBeforeEndTime = startTimeStamp <= endTimeStamp

		guard bothTimeStampsAreZero || startTimeIsBeforeEndTime else {
			Log.error("startTimeStamp must be less than endTimeStamp or both should be 0", log: .checkin)
			onError(CheckinQRScannerError.invalidTimeStamps)
			return
		}
		onSuccess(traceLocation)
	}
	
	// MARK: - Private

	private let kMaxDescriptionLength: Int = 255
	private let kMaxAddressLength: Int = 255

	private let appConfigurationProvider: AppConfigurationProviding

}
