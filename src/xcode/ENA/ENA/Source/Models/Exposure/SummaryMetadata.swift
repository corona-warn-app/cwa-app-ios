//
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification

struct SummaryMetadata: Codable {
	let summary: CodableExposureDetectionSummary
	let date: Date
}

extension SummaryMetadata {
	init(detectionSummary: ENExposureDetectionSummary, date: Date = Date()) {
		self.summary = CodableExposureDetectionSummary(with: detectionSummary)
		self.date = date
	}
}
