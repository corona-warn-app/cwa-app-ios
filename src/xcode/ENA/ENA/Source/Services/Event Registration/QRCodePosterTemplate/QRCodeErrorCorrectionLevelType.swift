////
// 🦠 Corona-Warn-App
//

import Foundation

enum MappedErrorCorrectionType: Int {
	case medium
	case large
	case quartile
	case high
	
	var mappedValue: String {
		switch self {
		case .medium:
			return "M"
		case .large:
			return "L"
		case .quartile:
			return "Q"
		case .high:
			return "H"
		}
	}
	
	init(qrCodeErrorCorrectionLevel: SAP_Internal_V2_PresenceTracingParameters.QRCodeErrorCorrectionLevel) {
		self = MappedErrorCorrectionType(rawValue: qrCodeErrorCorrectionLevel.rawValue) ?? .medium
	}
}
