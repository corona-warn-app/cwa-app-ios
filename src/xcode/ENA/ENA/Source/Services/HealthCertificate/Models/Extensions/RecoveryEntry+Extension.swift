////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

extension RecoveryEntry {

	var localCertificateValidityStartDate: Date? {
		return ISO8601DateFormatter.justLocalDateFormatter.date(from: certificateValidFrom)
	}

	var localCertificateValidityEndDate: Date? {
		return ISO8601DateFormatter.justLocalDateFormatter.date(from: certificateValidUntil)
	}

}
