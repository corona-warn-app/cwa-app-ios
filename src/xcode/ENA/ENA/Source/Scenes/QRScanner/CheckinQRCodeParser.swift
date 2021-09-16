//
// 🦠 Corona-Warn-App
//

import Foundation

// should replace CheckinQRCodeScannerViewModel

class CheckinQRCodeParser: QRCodeParsable {
	func parse(qrCode: String, completion: @escaping (Result<QRCodeResult, QRCodeParserError>) -> Void) {
		verificationHelper.verifyQrCode(
			qrCodeString: qrCode,
			appConfigurationProvider: appConfiguration,
			onSuccess: { [weak self] traceLocation in
				completion(.success(.checkin(traceLocation)))
				self?.verificationHelper.subscriptions.removeAll()
			},
			onError: { [weak self] error in
				completion(.failure(.checkinQrError(error)))
				self?.verificationHelper.subscriptions.removeAll()
			}
		)
	}
	
	// MARK: - Init

	init(
		verificationHelper: QRCodeVerificationHelper,
		appConfiguration: AppConfigurationProviding
	) {
		self.appConfiguration = appConfiguration
		self.verificationHelper = verificationHelper
	}
	
	// MARK: - Private

	private let appConfiguration: AppConfigurationProviding
	private let verificationHelper: QRCodeVerificationHelper

}
