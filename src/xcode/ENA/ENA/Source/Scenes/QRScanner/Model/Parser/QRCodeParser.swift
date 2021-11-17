//
// 🦠 Corona-Warn-App
//

import Foundation

protocol QRCodeParsable {
	/// Function to be called to parse a qrCode.
	/// - Parameters:
	///   - qrCode: The scanned qrCode as String
	///   - completion: If parsing was successful, we receive a QRCodeResult. If there encountered an error, we receive a QRCodeParserError
	func parse(
		qrCode: String,
		completion: @escaping (Result<QRCodeResult, QRCodeParserError>) -> Void
	)
}

class QRCodeParser: QRCodeParsable {

	init(
		appConfigurationProvider: AppConfigurationProviding,
		healthCertificateService: HealthCertificateService,
		markCertificateAsNew: Bool
	) {
		self.appConfigurationProvider = appConfigurationProvider
		self.healthCertificateService = healthCertificateService
		self.markCertificateAsNew = markCertificateAsNew
	}

	// MARK: - Protocol QRCodeParsable

	func parse(
		qrCode: String,
		completion: @escaping (Result<QRCodeResult, QRCodeParserError>) -> Void
	) {
		var parser: QRCodeParsable?

		// Check the prefix to know which type
		// if we go directly and try to parse we might get an incorrect error
		// e.g: scanning a PCR QRCode and trying to parse it at a health-certificate, we will get a healthCertificate related error
		// which is incorrect and it should be a Corona test error, so we need to have an idea about the type of qrcode before parsing it

		let antigenTestPrefix = "https://s.coronawarn.app"
		let pcrTestPrefix = "https://localhost"
		let healthCertificatePrefix = "HC1:"

		// Trace location QR codes need to be matched with a regex provided by the app configuration
		var traceLocationMatch: NSTextCheckingResult?
		let traceLocationDescriptor = appConfigurationProvider.currentAppConfig.value.presenceTracingParameters.qrCodeDescriptors.first {
			do {
				let regex = try NSRegularExpression(pattern: $0.regexPattern, options: [.caseInsensitive])
				traceLocationMatch = regex.firstMatch(in: qrCode, range: .init(location: 0, length: qrCode.count))
				return traceLocationMatch != nil
			} catch {
				Log.error(error.localizedDescription, log: .checkin)
				return false
			}
		}

		if traceLocationMatch != nil, traceLocationDescriptor != nil {
			// it is a trace Locations QRCode
			parser = CheckinQRCodeParser(
				appConfigurationProvider: appConfigurationProvider
			)
		} else if String(qrCode.prefix(antigenTestPrefix.count)).lowercased() == antigenTestPrefix || String(qrCode.prefix(pcrTestPrefix.count)).lowercased() == pcrTestPrefix {
			// it is a test
			parser = CoronaTestsQRCodeParser()
		} else if qrCode.prefix(healthCertificatePrefix.count) == healthCertificatePrefix {
			// it is a digital certificate
			parser = HealthCertificateQRCodeParser(
				healthCertificateService: healthCertificateService,
				markAsNew: markCertificateAsNew
			)
		} else if qrCode.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("{") {
			parser = TicketValidationQRCodeParser()
		}

		guard parser != nil else {
			Log.error("QRCode parser not initialized, Scanned code prefix doesn't match any of the scannable structs", log: .qrCode, error: nil)
			completion(.failure(.scanningError(.codeNotFound)))
			return
		}

		parser?.parse(qrCode: qrCode) { result in
			completion(result)

			/// Setting to nil keeps the parser in memory up until this point. Using a property to keep it in memory is not advisable as it led to a bug:
			/// The QRCodeParser instance is shared and concurrently used, but a separate parser is actually needed per call. Storing the parser in a property can lead to the wrong parser being used.
			parser = nil
		}
	}

	// MARK: - Private

	private let appConfigurationProvider: AppConfigurationProviding
	private let healthCertificateService: HealthCertificateService
	private let markCertificateAsNew: Bool

}
