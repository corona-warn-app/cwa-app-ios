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

	private let detectionResult: DetectionResult

	init(_ detectionHandler: DetectionResult = (nil, ENError(.notAuthorized))) {
		self.detectionResult = detectionHandler
	}

	func detectExposures(configuration: ENExposureConfiguration, diagnosisKeyURLs: [URL], completionHandler: @escaping ENDetectExposuresHandler) -> Progress {
		completionHandler(detectionResult.0, detectionResult.1)

		return Progress(totalUnitCount: 1)
	}
}
