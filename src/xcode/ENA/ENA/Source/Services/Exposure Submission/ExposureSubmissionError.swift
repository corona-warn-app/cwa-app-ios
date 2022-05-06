//
// 🦠 Corona-Warn-App
//

import Foundation

enum ExposureSubmissionError: Error, Equatable {
	case unsupported
	case `internal`
	case rateLimited
	case enNotEnabled
	case notAuthorized
	case other(String)
	case unknown
}

extension ExposureSubmissionError: LocalizedError {
	var errorDescription: String? {
		switch self {
		case .unsupported:
			return AppStrings.Common.enError5Description
		case .internal:
			return AppStrings.Common.enError11Description
		case .rateLimited:
			return AppStrings.Common.enError13Description
		case .enNotEnabled:
			return AppStrings.ExposureSubmissionError.enNotEnabled
		case .notAuthorized:
			return AppStrings.ExposureSubmissionError.notAuthorized
		case let .other(desc):
			return  "\(AppStrings.ExposureSubmissionError.other)\(desc)\(AppStrings.ExposureSubmissionError.otherend)"
		case .unknown:
			return  "\(AppStrings.ExposureSubmissionError.other) unknown \(AppStrings.ExposureSubmissionError.otherend)"
		}
	}
}
