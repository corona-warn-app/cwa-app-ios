//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation

extension SAP_External_Exposurenotification_TemporaryExposureKey: Comparable {
	static func < (lhs: SAP_External_Exposurenotification_TemporaryExposureKey, rhs: SAP_External_Exposurenotification_TemporaryExposureKey) -> Bool {
		lhs.rollingStartIntervalNumber > rhs.rollingStartIntervalNumber
	}
}

#endif
