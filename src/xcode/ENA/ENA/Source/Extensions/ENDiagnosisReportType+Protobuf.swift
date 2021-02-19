////
// 🦠 Corona-Warn-App
//

import ExposureNotification

extension ENDiagnosisReportType {
	var protobuf: SAP_Internal_Ppdd_PPAExposureWindowReportType? {
		SAP_Internal_Ppdd_PPAExposureWindowReportType(rawValue: Int(self.rawValue))
	}
}
