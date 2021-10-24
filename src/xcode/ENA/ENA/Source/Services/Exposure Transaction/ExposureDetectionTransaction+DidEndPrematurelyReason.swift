//
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification

extension ExposureDetection {
	enum DidEndPrematurelyReason: Error {
		/// Delegate was unable to provide an exposure manager to the transaction.
		case noExposureManager
		/// The actual exposure detection was started but did produce an error.
		case noExposureWindows(Error, Date)
		/// It was not possible to determine the remote days and/or hours that can be loaded.
		case noDaysAndHours
		/// Unable to get exposure configuration
		case noExposureConfiguration
		/// Unable to write diagnosis keys
		case unableToWriteDiagnosisKeys
		/// Unable to get supported countries
		case noSupportedCountries
		/// User has the wrong device time, no risk calculation possible
		case wrongDeviceTime
	}
}

extension ExposureDetection.DidEndPrematurelyReason: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .noExposureManager:
			return AppStrings.ExposureDetectionError.errorAlertMessage + " Code: NoExposureManager"
		case .unableToWriteDiagnosisKeys:
			return AppStrings.ExposureDetectionError.errorAlertMessage + " Code: DiagnosisKeys"
		case .noExposureWindows(let error, _):
			if let enError = error as? ENError {
				switch enError.code {
				case .unsupported:
					return AppStrings.Common.enError5Description
				case .internal:
					return AppStrings.Common.enError11Description
				case .rateLimited:
					return AppStrings.Common.enError13Description
				default:
					return AppStrings.ExposureDetectionError.errorAlertMessage + " EN Code: \(enError.code.rawValue)"
				}

			} else if let exposureDetectionError = error as? ExposureDetectionError {
				switch exposureDetectionError {
				case .isAlreadyRunning:
					return AppStrings.ExposureDetectionError.errorAlertMessage + " Code: ExposureDetectionIsAlreadyRunning"
				}
			} else {
				return AppStrings.ExposureDetectionError.errorAlertMessage + " Code: NoExposureWindows"
			}
		case .noDaysAndHours:
			return AppStrings.ExposureDetectionError.errorAlertMessage + " Code: NoDaysAndHours"
		case .noExposureConfiguration:
			return AppStrings.ExposureDetectionError.errorAlertMessage + " Code: NoExposureConfiguration"
		case .noSupportedCountries:
			return AppStrings.ExposureDetectionError.errorAlertMessage + " Code: NoSupportedCountries"
		case .wrongDeviceTime:
			return AppStrings.ExposureDetectionError.errorAlertWrongDeviceTime
		}
		
	}
}
