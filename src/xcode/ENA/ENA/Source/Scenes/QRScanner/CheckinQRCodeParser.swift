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
	
	func didAppear() {
//		#if DEBUG
//		if isUITesting {
//			let traceLocation = TraceLocation(
//				id: UUID().uuidString.data(using: .utf8) ?? Data(),
//				version: 0,
//				type: .locationTypePermanentRetail,
//				description: "Supermarkt",
//				address: "Walldorf",
//				startDate: nil,
//				endDate: nil,
//				defaultCheckInLengthInMinutes: nil,
//				cryptographicSeed: Data(),
//				cnPublicKey: Data()
//			)
//			onSuccess(traceLocation)
//		}
//		#endif
		
		// TODO should move to QRScannerViewModel somehow
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
