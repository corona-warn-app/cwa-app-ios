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
		// which is incorrect and it should be a Corona test error, so we need to have an idea about the type of qrcode before paring it

		let traceLocationsPrefix = "https://e.coronawarn.app"
		let antigenTestPrefix = "https://s.coronawarn.app"
		let pcrTestPrefix = "https://localhost"
		let healthCertificatePrefix = "HC1:"

		if qrCode.prefix(traceLocationsPrefix.count) == traceLocationsPrefix {
			// it is a trace Locations QRCode
			parser = CheckinQRCodeParser(
				appConfigurationProvider: appConfigurationProvider
			)
		} else if qrCode.prefix(antigenTestPrefix.count) == antigenTestPrefix || qrCode.prefix(pcrTestPrefix.count) == pcrTestPrefix {
			// it is a test
			parser = CoronaTestsQRCodeParser()
		} else if qrCode.prefix(healthCertificatePrefix.count) == healthCertificatePrefix {
			// it is a digital certificate
			parser = HealthCertificateQRCodeParser(
				healthCertificateService: healthCertificateService,
				markAsNew: markCertificateAsNew
			)
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
