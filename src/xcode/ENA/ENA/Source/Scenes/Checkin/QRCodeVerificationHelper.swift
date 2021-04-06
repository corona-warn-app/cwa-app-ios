////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

protocol QRCodeVerificationHelperProviding {
	func verifyQrCode(
		qrCodeString url: String,
		appConfigurationProvider: AppConfigurationProviding,
		onSuccess: @escaping((TraceLocation) -> Void),
		onError: @escaping((QRScannerError) -> Void)
	)
}
class QRCodeVerificationHelper {
	
	private var subscriptions: Set<AnyCancellable> = []

	func verifyQrCode(
		qrCodeString url: String,
		appConfigurationProvider: AppConfigurationProviding,
		onSuccess: @escaping((TraceLocation) -> Void),
		onError: @escaping((QRScannerError) -> Void)

	) {
		appConfigurationProvider.appConfiguration().sink { appConfig in
			
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
			// for some reason we get an extra match at index 0 which is the entire URL so  we need to add an offset of 1 to each index after that to get the correct corresponding parts
			guard let unWrappedMatch = match,
				  let qrDescriptor = descriptor,
				  let payLoadIndex = descriptor?.encodedPayloadGroupIndex,
				  payLoadIndex < unWrappedMatch.numberOfRanges,
				  let payLoadRange = Range(unWrappedMatch.range(at: Int(payLoadIndex) + 1), in: url)
			else {
				Log.error("the QRCode matched none of the regular expressions", log: .checkin)
				onError(QRScannerError.codeNotFound)
				return
			}

			// let version = url[versionRange]
			let payLoad = url[payLoadRange]
			let encodingType = EncodingType(rawValue: qrDescriptor.payloadEncoding.rawValue) ?? .unspecified
			guard let traceLocation = TraceLocation(qrCodeString: String(payLoad), encoding: encodingType) else {
				onError(QRScannerError.codeNotFound)
				return
			}
			onSuccess(traceLocation)
		}.store(in: &subscriptions)
	}
}
