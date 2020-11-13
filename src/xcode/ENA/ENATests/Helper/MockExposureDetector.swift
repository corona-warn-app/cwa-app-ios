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

@testable import ENA
import ExposureNotification
import Foundation

class MockExposureDetector: ExposureDetector {
	typealias DetectionResult = (ENExposureDetectionSummary?, Error?)
	typealias ExposureWindowsResult = ([ENExposureWindow]?, Error?)

	private let detectionResult: DetectionResult
	private let exposureWindowsResult: ExposureWindowsResult

	init(
		detectionHandler: DetectionResult = (nil, ENError(.notAuthorized)),
		exposureWindowsHandler: ExposureWindowsResult = (nil, ENError(.notAuthorized))
	) {
		self.detectionResult = detectionHandler
		self.exposureWindowsResult = exposureWindowsHandler
	}

	func detectExposures(configuration: ENExposureConfiguration, diagnosisKeyURLs: [URL], completionHandler: @escaping ENDetectExposuresHandler) -> Progress {
		completionHandler(detectionResult.0, detectionResult.1)

		return Progress(totalUnitCount: 1)
	}

	func getExposureWindows(summary: ENExposureDetectionSummary, completionHandler: @escaping ENGetExposureWindowsHandler) -> Progress {
		completionHandler(exposureWindowsResult.0, exposureWindowsResult.1)

		return Progress(totalUnitCount: 1)
	}

}
