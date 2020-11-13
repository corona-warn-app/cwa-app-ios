//
// 🦠 Corona-Warn-App
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
