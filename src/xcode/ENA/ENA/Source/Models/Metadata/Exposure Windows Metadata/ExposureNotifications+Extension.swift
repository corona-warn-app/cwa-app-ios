////
// 🦠 Corona-Warn-App
//

import ExposureNotification

extension ENInfectiousness {
	var protobuf: SAP_Internal_Ppdd_PPAExposureWindowInfectiousness? {
		SAP_Internal_Ppdd_PPAExposureWindowInfectiousness(rawValue: Int(self.rawValue))
	}
}

extension ENDiagnosisReportType {
	var protobuf: SAP_Internal_Ppdd_PPAExposureWindowReportType? {
		SAP_Internal_Ppdd_PPAExposureWindowReportType(rawValue: Int(self.rawValue))
	}
}
