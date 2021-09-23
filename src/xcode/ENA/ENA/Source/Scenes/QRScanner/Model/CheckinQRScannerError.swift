////
// 🦠 Corona-Warn-App
//

import Foundation

enum CheckinQRScannerError: Error, LocalizedError {

	case codeNotFound // invalid url
	case invalidPayload
	case invalidVendorData
	case invalidAddress
	case invalidDescription
	case invalidCryptoSeed
	case invalidTimeStamps

	var errorDescription: String? {
		switch self {
		case .codeNotFound:
			return AppStrings.Checkins.QRScannerError.invalidURL
		case .invalidPayload:
			return AppStrings.Checkins.QRScannerError.invalidPayload
		case .invalidVendorData:
			return AppStrings.Checkins.QRScannerError.invalidVendorData
		case .invalidDescription:
			return AppStrings.Checkins.QRScannerError.invalidDescription
		case .invalidAddress:
			return AppStrings.Checkins.QRScannerError.invalidAddress
		case .invalidCryptoSeed:
			return AppStrings.Checkins.QRScannerError.invalidCryptographicSeed
		case .invalidTimeStamps:
			return AppStrings.Checkins.QRScannerError.invalidTimeStamps
		}
	}
}
