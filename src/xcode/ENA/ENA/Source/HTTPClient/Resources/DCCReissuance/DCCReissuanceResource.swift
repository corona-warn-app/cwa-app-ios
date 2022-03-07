//
// 🦠 Corona-Warn-App
//

import Foundation

enum DCCReissuanceResourceError: LocalizedError {

	case DCC_RI_PIN_MISMATCH
	case DCC_RI_PARSE_ERR
	case DCC_RI_NO_NETWORK
	case DCC_RI_400
	case DCC_RI_401
	case DCC_RI_403
	case DCC_RI_406
	case DCC_RI_429
	case DCC_RI_500
	case DCC_RI_CLIENT_ERR
	case DCC_RI_SERVER_ERR

	var errorDescription: String? {
		switch self {
		case .DCC_RI_PIN_MISMATCH:
			return "\(AppStrings.HealthCertificate.Reissuance.Errors.contactSupport) (DCC_RI_PIN_MISMATCH)"
		case .DCC_RI_PARSE_ERR:
			return "\(AppStrings.HealthCertificate.Reissuance.Errors.contactSupport) (DCC_RI_PARSE_ERR)"
		case .DCC_RI_NO_NETWORK:
			return "\(AppStrings.HealthCertificate.Reissuance.Errors.noNetwork) (DCC_RI_NO_NETWORK)"
		case .DCC_RI_400:
			return "\(AppStrings.HealthCertificate.Reissuance.Errors.tryAgain) (DCC_RI_400)"
		case .DCC_RI_401:
			return "\(AppStrings.HealthCertificate.Reissuance.Errors.notSupported) (DCC_RI_401)"
		case .DCC_RI_403:
			return "\(AppStrings.HealthCertificate.Reissuance.Errors.notSupported) (DCC_RI_403)"
		case .DCC_RI_406:
			return "\(AppStrings.HealthCertificate.Reissuance.Errors.tryAgain) (DCC_RI_406)"
		case .DCC_RI_429:
			return "\(AppStrings.HealthCertificate.Reissuance.Errors.tryAgain) (DCC_RI_429)"
		case .DCC_RI_500:
			return "\(AppStrings.HealthCertificate.Reissuance.Errors.tryAgain) (DCC_RI_500)"
		case .DCC_RI_CLIENT_ERR:
			return "\(AppStrings.HealthCertificate.Reissuance.Errors.tryAgain) (DCC_RI_CLIENT_ERR)"
		case .DCC_RI_SERVER_ERR:
			return "\(AppStrings.HealthCertificate.Reissuance.Errors.tryAgain) (DCC_RI_SERVER_ERR)"
		}
	}
}

struct ErrorCode: Decodable {
	let errorCode: String
	let message: String
}

struct DCCReissuanceResource: Resource {

	// MARK: - Init

	init(
		sendModel: DCCReissuanceSendModel,
		trustEvaluation: TrustEvaluating
	) {
		self.locator = .dccReissuance
		self.type = .default
		self.sendResource = JSONSendResource<DCCReissuanceSendModel>(sendModel)
		self.receiveResource = JSONReceiveResource<DCCReissuanceReceiveModel>()
		self.trustEvaluation = trustEvaluation
	}

	// MARK: - Protocol Resource

	let trustEvaluation: TrustEvaluating

	var locator: Locator
	var type: ServiceType
	var sendResource: JSONSendResource<DCCReissuanceSendModel>
	var receiveResource: JSONReceiveResource<DCCReissuanceReceiveModel>

	func customError(for error: ServiceError<DCCReissuanceResourceError>, responseBody: Data?) -> DCCReissuanceResourceError? {
		switch error {
		case .trustEvaluationError(let trustError):
			return trustEvaluationErrorHandling(trustError)
		case .resourceError:
			return .DCC_RI_PARSE_ERR
		case .transportationError:
			return .DCC_RI_NO_NETWORK
		case .unexpectedServerError(let statusCode):
			return unexpectedServerError(statusCode, responseBody)
		default:
			return nil
		}
	}

	// MARK: - Private

	private func trustEvaluationErrorHandling(
		_ trustEvaluationError: (TrustEvaluationError)
	) -> DCCReissuanceResourceError? {
		switch trustEvaluationError {
		case let .default(defaultTrustEvaluationError):
			switch defaultTrustEvaluationError {
			case .CERT_MISMATCH:
				return .DCC_RI_PIN_MISMATCH
			}
		default:
			return nil
		}
	}

	private func unexpectedServerError(
		_ statusCode: Int,
		_ responseBody: Data?
	) -> DCCReissuanceResourceError? {
		if let data = responseBody,
		   let errorCode = try? JSONDecoder().decode(ErrorCode.self, from: data) {
			Log.error("DCCReissuance error status code: \(statusCode), with ErrorCode model: \(errorCode)")
		}

		switch statusCode {
		case 400:
			return .DCC_RI_400
		case 401:
			return .DCC_RI_401
		case 403:
			return .DCC_RI_403
		case 406:
			return .DCC_RI_406
		case 429:
			return .DCC_RI_429
		case 402, 404, 405, 407...428, 430...499:
			return .DCC_RI_CLIENT_ERR
		case 500:
			return .DCC_RI_500
		case (501...599):
			return .DCC_RI_SERVER_ERR
		default:
			return nil
		}
	}
}
