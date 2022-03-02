//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine

enum HealthCertificateReissuanceError: LocalizedError {

	case submitFailedError
	case replaceHealthCertificateError(Error)
	case noRelation
	case certificateToReissueMissing
	case restServiceError(ServiceError<DCCReissuanceResourceError>)

	var errorDescription: String? {
		switch self {
		case .submitFailedError:
			return "\(AppStrings.HealthCertificate.Reissuance.Errors.tryAgain) (submitFailedError)"
		case .replaceHealthCertificateError:
			return "\(AppStrings.HealthCertificate.Reissuance.Errors.tryAgain) (replaceHealthCertificateError)"
		case .noRelation:
			return "\(AppStrings.HealthCertificate.Reissuance.Errors.contactSupport) (DCC_RI_NO_RELATION)"
		case .certificateToReissueMissing:
			return "\(AppStrings.HealthCertificate.Reissuance.Errors.tryAgain) (certificateToReissueMissing)"
		case .restServiceError(let serviceError):
			switch serviceError {
			case .receivedResourceError(let reissuanceResourceError):
				return reissuanceResourceError.localizedDescription
			default:
				return serviceError.localizedDescription
			}

		}
	}

}
