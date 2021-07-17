////
// 🦠 Corona-Warn-App
//

import ExposureNotification
import UIKit

final class NewMockExposureManager: NSObject {
	typealias MockDiagnosisKeysResult = ([ENTemporaryExposureKey]?, Error?)

	// MARK: Properties

	let exposureNotificationError: ExposureNotificationError?
	let diagnosisKeysResult: MockDiagnosisKeysResult?

	// MARK: Creating a Mocked Manager

	init(
		exposureNotificationError: ExposureNotificationError?,
		diagnosisKeysResult: MockDiagnosisKeysResult?
	) {
		self.exposureNotificationError = exposureNotificationError
		self.diagnosisKeysResult = diagnosisKeysResult

		#if RELEASE
		// This whole class would/should be wrapped in a DEBUG block. However, there were some
		// issues with the handling of cumminity and debug builds so we chose this way to prevent
		// malicious usage
		preconditionFailure("Don't use this mock in production!")
		#endif
	}
}
