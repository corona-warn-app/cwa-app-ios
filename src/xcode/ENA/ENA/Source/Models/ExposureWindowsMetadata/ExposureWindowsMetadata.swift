////
// 🦠 Corona-Warn-App
//

import Foundation

struct ExposureWindowsMetadata: Codable {
	
	// MARK: - Init
	
	init(
		newExposureWindowsQueue: [SubmittionExposureWindow],
		reportedExposureWindowsQueue: [SubmittionExposureWindow]) {
		
		self.newExposureWindowsQueue = newExposureWindowsQueue
		self.reportedExposureWindowsQueue = reportedExposureWindowsQueue
	}
	
	// MARK: - Protocol Codable
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		newExposureWindowsQueue = try container.decode([SubmittionExposureWindow].self, forKey: .newExposureWindowsQueue)
		reportedExposureWindowsQueue = try container.decode([SubmittionExposureWindow].self, forKey: .reportedExposureWindowsQueue)
	}
	
	enum CodingKeys: String, CodingKey {
		case newExposureWindowsQueue
		case reportedExposureWindowsQueue
	}
	
	// MARK: - Internal
	
	// Exposure Windows to be added to the next submittion
	var newExposureWindowsQueue: [SubmittionExposureWindow]
	
	// Exposure Windows that was sent in pervious submittions
	var reportedExposureWindowsQueue: [SubmittionExposureWindow]
	
	// Date used to delete Records in reportedExposureWindowsQueue which are older than 15 days
}

struct SubmittionExposureWindow: Codable {
	var exposureWindow: ExposureWindow
	var transmissionRiskLevel: Int
	var normalizedTime: Double
	var hash: String?
	var date: Date
	
	init(exposureWindow: ExposureWindow, transmissionRiskLevel: Int, normalizedTime: Double, hash: String?, date: Date) {
		self.exposureWindow = exposureWindow
		self.transmissionRiskLevel = transmissionRiskLevel
		self.normalizedTime = normalizedTime
		self.hash = hash
		self.date = date
	}
}
