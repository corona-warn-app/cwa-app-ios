//
// 🦠 Corona-Warn-App
//

import Foundation

enum QRScannerError: Error, LocalizedError {

	case cameraPermissionDenied
	case scanningDeactivated
	case codeNotFound
	case other(Error)

	var errorDescription: String? {
		switch self {
		case .cameraPermissionDenied:
			return AppStrings.UniversalQRScanner.Error.CameraPermissionDenied.message
		case .scanningDeactivated, .codeNotFound:
			return AppStrings.UniversalQRScanner.Error.unsupportedQRCode
		case .other(let error):
			return error.localizedDescription
		}
	}
}
// swiftlint:disable pattern_matching_keywords
extension QRScannerError: Equatable {
	public static func == (lhs: QRScannerError, rhs: QRScannerError) -> Bool {
		switch (lhs, rhs) {
		case (.cameraPermissionDenied, .cameraPermissionDenied):
			return true
		case (.codeNotFound, .codeNotFound):
			return true
		case (.scanningDeactivated, .scanningDeactivated):
			return true
		case (.other(let errorLhs), .other(let errorRhs)):
			return errorLhs.localizedDescription == errorRhs.localizedDescription
		default:
			return false
		}
	}
}
