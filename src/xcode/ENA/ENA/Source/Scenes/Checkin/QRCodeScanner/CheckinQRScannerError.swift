////
// 🦠 Corona-Warn-App
//

import Foundation

enum CheckinQRScannerError: Error, LocalizedError {

	case cameraPermissionDenied
	case codeNotFound // invalid url
	case invalidPayload
	case invalidVendorData
	case invalidAddress
	case invalidDescription
	case invalidCryptoSeed
	case invalidTimeStamps
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
		case .invalidDescription:
			return AppStrings.Checkins.QRScanner.Error.invalidDescription
		case .invalidAddress:
			return AppStrings.Checkins.QRScanner.Error.invalidAddress
		case .invalidCryptoSeed:
			return AppStrings.Checkins.QRScanner.Error.invalidCryptographicSeed
		case .invalidTimeStamps:
			return AppStrings.Checkins.QRScanner.Error.invalidTimeStamps
		default:
			return AppStrings.ExposureSubmissionQRScanner.otherError
		}
	}
}
