////
// 🦠 Corona-Warn-App
//

import Foundation

struct ExposureWindowsMetadata: Codable {
	
	// MARK: - Init
	
	init(
		newExposureWindowsQueue: [SubmissionExposureWindow],
		reportedExposureWindowsQueue: [SubmissionExposureWindow]
	) {
		self.newExposureWindowsQueue = newExposureWindowsQueue
		self.reportedExposureWindowsQueue = reportedExposureWindowsQueue
	}
	
	// MARK: - Protocol Codable
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		newExposureWindowsQueue = try container.decode([SubmissionExposureWindow].self, forKey: .newExposureWindowsQueue)
		reportedExposureWindowsQueue = try container.decode([SubmissionExposureWindow].self, forKey: .reportedExposureWindowsQueue)
	}
	
	enum CodingKeys: String, CodingKey {
		case newExposureWindowsQueue
		case reportedExposureWindowsQueue
	}
	
	// MARK: - Internal
	
	// Exposure Windows to be added to the next Submission
	var newExposureWindowsQueue: [SubmissionExposureWindow]
	
	// Exposure Windows that was sent in pervious Submissions
	var reportedExposureWindowsQueue: [SubmissionExposureWindow]
	
	// Date used to delete Records in reportedExposureWindowsQueue which are older than 15 days
}

struct SubmissionExposureWindow: Codable {

	// MARK: - Init

	init(exposureWindow: ExposureWindow, transmissionRiskLevel: Int, normalizedTime: Double, hash: String?, date: Date) {
		self.exposureWindow = exposureWindow
		self.transmissionRiskLevel = transmissionRiskLevel
		self.normalizedTime = normalizedTime
		self.hash = hash
		self.date = date
	}
	
	// MARK: - Internal

	var exposureWindow: ExposureWindow
	var transmissionRiskLevel: Int
	var normalizedTime: Double
	var hash: String?
	var date: Date
}
