////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

 protocol QRCodeErrorCorrectionLevelProviding {
	func errorCorrectionLevel(
		appConfigurationProvider: AppConfigurationProviding,
		onCompletion: @escaping((String) -> Void)
	)
 }

class QRCodeErrorCorrectionLevelProvider {
	private var subscriptions: Set<AnyCancellable> = []

	func errorCorrectionLevel(
		appConfigurationProvider: AppConfigurationProviding,
		onSuccess: @escaping((String) -> Void)
	) {
		appConfigurationProvider.appConfiguration().sink { appConfig in
			let qrCodeErrorCorrectionLevel = appConfig.presenceTracingParameters.qrCodeErrorCorrectionLevel
			var mappedErrorCorrectionLevel
			
			switch qrCodeErrorCorrectionLevel {
			case .medium:
				mappedErrorCorrectionLevel = "M"
			case .low:
				mappedErrorCorrectionLevel = "L"
			case .quantile:
				mappedErrorCorrectionLevel = "Q"
			case .high:
				mappedErrorCorrectionLevel = "H"
			default:
				mappedErrorCorrectionLevel = "H"
			}
			onSuccess(mappedErrorCorrectionLevel)
		}.store(in: &subscriptions)
	}
}
