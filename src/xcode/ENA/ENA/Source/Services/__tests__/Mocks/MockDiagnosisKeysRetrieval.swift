//
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification

#if DEBUG
final class MockDiagnosisKeysRetrieval {

	typealias MockDiagnosisKeysResult = ([ENTemporaryExposureKey]?, Error?)
	let diagnosisKeysResult: MockDiagnosisKeysResult

	init(diagnosisKeysResult: MockDiagnosisKeysResult) {
		self.diagnosisKeysResult = diagnosisKeysResult
	}
}

extension MockDiagnosisKeysRetrieval: DiagnosisKeysRetrieval {
	var exposureManagerState: ExposureManagerState {
		return .init(authorized: true, enabled: true, status: .active)
	}

	func getTestDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler) {
		completionHandler(diagnosisKeysResult.0, diagnosisKeysResult.1)
	}

	func accessDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler) {
		completionHandler(diagnosisKeysResult.0, diagnosisKeysResult.1)
	}
}
#endif
