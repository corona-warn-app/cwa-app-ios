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
	case DCC_RI_500
	case DCC_RI_CLIENT_ERR
	case DCC_RI_SERVER_ERR

	var errorDescription: String? {
		switch self {
			// TODO add correct error strings
		case .DCC_RI_PIN_MISMATCH:
			return "someError"
		case .DCC_RI_PARSE_ERR:
			return "someError"
		case .DCC_RI_NO_NETWORK:
			return "someError"
		case .DCC_RI_400:
			return "someError"
		case .DCC_RI_401:
			return "someError"
		case .DCC_RI_403:
			return "someError"
		case .DCC_RI_406:
			return "someError"
		case .DCC_RI_500:
			return "someError"
		case .DCC_RI_CLIENT_ERR:
			return "someError"
		case .DCC_RI_SERVER_ERR:
			return "someError"
		}
	}
}

struct DCCReissuanceResource: Resource {

	// MARK: - Init

	init(
		sendModel: DCCReissuanceSendModel
	) {
		self.locator = .dccReissuance
		self.type = .dynamicPinning
		self.sendResource = JSONSendResource<DCCReissuanceSendModel>(sendModel)
		self.receiveResource = JSONReceiveResource<[DCCReissuanceReceiveModel]>()
	}

	// MARK: - Protocol Resource

	var locator: Locator
	var type: ServiceType
	var sendResource: JSONSendResource<DCCReissuanceSendModel>
	var receiveResource: JSONReceiveResource<[DCCReissuanceReceiveModel]>

	func customError(for error: ServiceError<DCCReissuanceResourceError>) -> DCCReissuanceResourceError? {
		switch error {
			// TODO check for correct error
		case .trustEvaluationError:
			return .DCC_RI_PIN_MISMATCH
		case .resourceError:
			return .DCC_RI_PARSE_ERR
		case .transportationError:
			return .DCC_RI_NO_NETWORK
		case .unexpectedServerError(let statusCode):
			return unexpectedServerError(statusCode)
		default:
			return nil
		}
	}

	// MARK: - Private

	private func unexpectedServerError(_ statusCode: Int) -> DCCReissuanceResourceError? {
		switch statusCode {
		case 400:
			return .DCC_RI_400
		case 401:
			return .DCC_RI_401
		case 403:
			return .DCC_RI_403
		case 406:
			return .DCC_RI_406
		case 402, 405, 407...499:
			return .DCC_RI_CLIENT_ERR
		case (500...599):
			return .DCC_RI_SERVER_ERR
		default:
			return nil
		}
	}
}
