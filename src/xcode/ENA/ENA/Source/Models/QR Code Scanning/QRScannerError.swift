//
// 🦠 Corona-Warn-App
//

import Foundation

enum QRScannerError: Error, LocalizedError {

	case cameraPermissionDenied
	case codeNotFound
	case other(Error)

	var errorDescription: String? {
		switch self {
		case .cameraPermissionDenied:
			return AppStrings.ExposureSubmissionQRScanner.cameraPermissionDenied
		case .other(let error):
			return error.localizedDescription
		default:
			return AppStrings.ExposureSubmissionQRScanner.otherError
		}
	}

}
