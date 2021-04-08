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
		case .codeNotFound:
			return AppStrings.Checkins.QRScanner.Error.invalidURL
		case .invalidPayload:
			return AppStrings.Checkins.QRScanner.Error.invalidPayload
		case .invalidVendorData:
			return AppStrings.Checkins.QRScanner.Error.invalidVendorData
		default:
			return AppStrings.ExposureSubmissionQRScanner.otherError
		}
	}
}
