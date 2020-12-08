//
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification

#if DEBUG
final class MockDiagnosisKeysRetrieval: DiagnosisKeysRetrieval {

	typealias MockDiagnosisKeysResult = ([ENTemporaryExposureKey]?, Error?)

	// MARK: - Init

	init(
		diagnosisKeysResult: MockDiagnosisKeysResult,
		exposureManagerState: ExposureManagerState = .init(authorized: true, enabled: true, status: .active)
	) {
		self.diagnosisKeysResult = diagnosisKeysResult
		self.exposureManagerState = exposureManagerState
	}

	// MARK: - Protocol DiagnosisKeysRetrieval

	func getTestDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler) {
		completionHandler(diagnosisKeysResult.0, diagnosisKeysResult.1)
	}

	func accessDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler) {
		completionHandler(diagnosisKeysResult.0, diagnosisKeysResult.1)
	}

	// MARK: - Internal

	let diagnosisKeysResult: MockDiagnosisKeysResult
	let exposureManagerState: ExposureManagerState

}
#endif
