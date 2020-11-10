//
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
//

import XCTest
import ExposureNotification
@testable import ENA

class ExposureManagerTests: XCTestCase {

	func test_GIVEN_RunningDetection_When_StartNewDetection_Then_SameProgressReturned() {
		let managerSpy = ManagerSpy()
		let exposureManager = ENAExposureManager(manager: managerSpy)

		let progress1 = exposureManager.detectExposures(configuration: ENExposureConfiguration(), diagnosisKeyURLs: []) { _, _ in
		}

		let progress2 = exposureManager.detectExposures(configuration: ENExposureConfiguration(), diagnosisKeyURLs: []) { _, _ in
		}

		XCTAssertEqual(progress1, progress2)
	}

	func test_GIVEN_CanceledDetection_When_StartNewDetection_Then_NewProgressReturned() {
		let managerSpy = ManagerSpy()
		let exposureManager = ENAExposureManager(manager: managerSpy)

		let progress1 = exposureManager.detectExposures(configuration: ENExposureConfiguration(), diagnosisKeyURLs: []) { _, _ in
		}

		progress1.cancel()

		let progress2 = exposureManager.detectExposures(configuration: ENExposureConfiguration(), diagnosisKeyURLs: []) { _, _ in
		}

		XCTAssertNotEqual(progress1, progress2)
	}

	func test_GIVEN_FinishedDetection_When_StartNewDetection_Then_NewProgressReturned() {
		let managerSpy = ManagerSpy()
		let exposureManager = ENAExposureManager(manager: managerSpy)

		let progress1 = exposureManager.detectExposures(configuration: ENExposureConfiguration(), diagnosisKeyURLs: []) { _, _ in
		}

		// Simulate isFinished state.
		progress1.totalUnitCount = 1
		progress1.completedUnitCount = 1

		let progress2 = exposureManager.detectExposures(configuration: ENExposureConfiguration(), diagnosisKeyURLs: []) { _, _ in
		}

		XCTAssertNotEqual(progress1, progress2)
	}

	func test_GIVEN_RunningDetection_When_StartNewDetection_Then_DetectExposuresNotCalled() {
		let managerSpy = ManagerSpy()
		let exposureManager = ENAExposureManager(manager: managerSpy)

		_ = exposureManager.detectExposures(configuration: ENExposureConfiguration(), diagnosisKeyURLs: []) { _, _ in
		}

		_ = exposureManager.detectExposures(configuration: ENExposureConfiguration(), diagnosisKeyURLs: []) { _, _ in
		}

		XCTAssertEqual(managerSpy.numberOfDetectionCalls, 1)
	}
}

private final class ManagerSpy: NSObject, Manager {

	static var authorizationStatus: ENAuthorizationStatus = .unknown

	var numberOfDetectionCalls = 0

	func detectExposures(configuration: ENExposureConfiguration, diagnosisKeyURLs: [URL], completionHandler: @escaping ENDetectExposuresHandler) -> Progress {
		numberOfDetectionCalls += 1
		return Progress()
	}

	func activate(completionHandler: @escaping ENErrorHandler) { }

	func invalidate() { }

	var invalidationHandler: (() -> Void)?

	var exposureNotificationEnabled: Bool = false

	func setExposureNotificationEnabled(_ enabled: Bool, completionHandler: @escaping ENErrorHandler) { }

	var exposureNotificationStatus: ENStatus = .unknown

	func getDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler) { }

	func getTestDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler) { }

}
