////
// 🦠 Corona-Warn-App
//

import ExposureNotification

extension ENInfectiousness {
	var protobuf: SAP_Internal_Ppdd_PPAExposureWindowInfectiousness? {
		SAP_Internal_Ppdd_PPAExposureWindowInfectiousness(rawValue: Int(self.rawValue))
	}
}
