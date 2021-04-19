////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

 protocol QRCodeErrorCorrectionLevelProviding {
	func errorCorrectionLevel(
		appConfigurationProvider: AppConfigurationProviding,
		onCompletion: @escaping((MappedErrorCorrectionType) -> Void)
	)
 }

class QRCodeErrorCorrectionLevelProvider {
	private var subscriptions: Set<AnyCancellable> = []

	func errorCorrectionLevel(
		appConfigurationProvider: AppConfigurationProviding,
		onCompletion: @escaping((MappedErrorCorrectionType) -> Void)
	) {
		appConfigurationProvider.appConfiguration().sink { appConfig in
			let qrCodeErrorCorrectionLevel = appConfig.presenceTracingParameters.qrCodeErrorCorrectionLevel
			let mappedErrorCorrectionLevel = MappedErrorCorrectionType(qrCodeErrorCorrectionLevel: qrCodeErrorCorrectionLevel)
			
			onCompletion(mappedErrorCorrectionLevel)
		}.store(in: &subscriptions)
	}
}
