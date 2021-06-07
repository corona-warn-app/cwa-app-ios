////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

extension TestEntry {

	var sampleCollectionDate: Date? {
		let iso8601FormatterWithFractionalSeconds = ISO8601DateFormatter()
		iso8601FormatterWithFractionalSeconds.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

		return iso8601FormatterWithFractionalSeconds.date(from: dateTimeOfSampleCollection) ??
			ISO8601DateFormatter().date(from: dateTimeOfSampleCollection)
	}

}
