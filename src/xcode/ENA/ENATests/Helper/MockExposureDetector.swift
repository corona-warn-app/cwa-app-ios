//
// 🦠 Corona-Warn-App
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
