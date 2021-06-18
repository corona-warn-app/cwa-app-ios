////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

extension TestEntry {

	static let pcrTypeString = "LP6464-4"
	static let antigenTypeString = "LP217198-3"

	var sampleCollectionDate: Date? {
		let iso8601FormatterWithFractionalSeconds = ISO8601DateFormatter()
		iso8601FormatterWithFractionalSeconds.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

		return iso8601FormatterWithFractionalSeconds.date(from: dateTimeOfSampleCollection) ??
			ISO8601DateFormatter().date(from: dateTimeOfSampleCollection)
	}

	var coronaTestType: CoronaTestType? {
		switch typeOfTest {
		case Self.pcrTypeString:
			return .pcr
		case Self.antigenTypeString:
			return .antigen
		default:
			return nil
		}
	}

}
