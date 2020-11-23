//
// 🦠 Corona-Warn-App
//

import ExposureNotification

extension ENTemporaryExposureKey {
	var sapKey: SAP_External_Exposurenotification_TemporaryExposureKey {
		SAP_External_Exposurenotification_TemporaryExposureKey.with {
			$0.keyData = self.keyData
			$0.rollingPeriod = Int32(self.rollingPeriod)
			$0.rollingStartIntervalNumber = Int32(self.rollingStartNumber)
			$0.transmissionRiskLevel = Int32(self.transmissionRiskLevel)
		}
	}
}
