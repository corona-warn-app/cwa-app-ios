// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ExposureNotification
import UIKit

final class MockExposureManager {
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
	}
}

extension MockExposureManager: ExposureManager {
	func invalidate() {}

	func activate(completion: @escaping CompletionHandler) {
		completion(exposureNotificationError)
	}

	func enable(completion: @escaping CompletionHandler) {
		completion(exposureNotificationError)
	}

	func disable(completion: @escaping CompletionHandler) {
		completion(exposureNotificationError)
	}

	func preconditions() -> ExposureManagerState {
		ExposureManagerState(authorized: true, enabled: true, status: .active)
	}

	func detectExposures(configuration _: ENExposureConfiguration, diagnosisKeyURLs _: [URL], completionHandler _: @escaping ENDetectExposuresHandler) -> Progress {
		Progress()
	}

	func getTestDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler) {
		completionHandler(diagnosisKeysResult!.0, diagnosisKeysResult!.1)
	}

	func accessDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler) {
		completionHandler(diagnosisKeysResult!.0, diagnosisKeysResult!.1)
	}

	func resume(observer: ENAExposureManagerObserver) {	}

	func alertForBluetoothOff(completion: @escaping () -> Void) -> UIAlertController? { return nil }

	func requestUserNotificationsPermissions(completionHandler: @escaping (() -> Void)) {
		completionHandler()
	}
}
