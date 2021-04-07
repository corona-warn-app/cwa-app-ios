////
// 🦠 Corona-Warn-App
//

import Foundation

enum CheckinQRScannerError: Error, LocalizedError {

	case cameraPermissionDenied
	case codeNotFound // invalid url
	case invalidPayload
	case invalidVendorData
	case other

	var errorDescription: String? {
		switch self {
		case .cameraPermissionDenied:
			return AppStrings.ExposureSubmissionQRScanner.cameraPermissionDenied
		default:
			return AppStrings.ExposureSubmissionQRScanner.otherError
		}
	}
}
