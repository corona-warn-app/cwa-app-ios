//
// 🦠 Corona-Warn-App
//

import Foundation

enum OTPAuthorizationError: LocalizedError, Equatable {

	case generalError(underlyingError: Error? = nil)
	case invalidResponseError
	case internalServerError
	case otpAlreadyUsedThisMonth
	case otherServerError
	case apiTokenAlreadyIssued
	case apiTokenExpired
	case apiTokenQuotaExceeded
	case deviceBlocked
	case deviceTokenInvalid
	case deviceTokenRedeemed
	case deviceTokenSyntaxError
	case noNetworkConnection
	
	var description: String {
		switch self {
		case .generalError(let error):
			if let e = error?.localizedDescription {
				return "generalError with underlying: \(e)"
			} else {
				return "generalError"
			}
		case .invalidResponseError:
			return "INVALID_RESPONSE_ERROR"
		case .internalServerError:
			return "INTERNAL_SERVER_ERROR"
		case .otpAlreadyUsedThisMonth:
			return "OTP_ALREADY_USED_THIS_MONTH"
		case .otherServerError:
			return "OTHER_SERVER_ERROR"
		case .apiTokenAlreadyIssued:
			return "API_TOKEN_ALEARY_ISSUED"
		case .apiTokenExpired:
			return "API_TOKEN_EXPIRED"
		case .apiTokenQuotaExceeded:
			return "API_TOKEN_QUOTA_EXEEDED"
		case .deviceBlocked:
			return "DEVICE_BLOCKED"
		case .deviceTokenInvalid:
			return "DEVICE_TOKEN_INVALID"
		case .deviceTokenRedeemed:
			return "DEVICE_TOKEN_REDEEMED"
		case .deviceTokenSyntaxError:
			return "DEVICE_TOKEN_SYNTAX_ERROR"
		case .noNetworkConnection:
			return "NO_NETWORK_CONNECTION"
		}
	}

	static func == (lhs: OTPAuthorizationError, rhs: OTPAuthorizationError) -> Bool {
		return lhs.description == rhs.description
	}

}

struct OTPAuthorizationForELSResource: Resource {
	
	// MARK: - Init

	init(
		otpEls: String,
		ppacToken: PPACToken,
		trustEvaluation: TrustEvaluating = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHashData
		)
	) {
		let ppacIos = SAP_Internal_Ppdd_PPACIOS.with {
			$0.apiToken = ppacToken.apiToken
			$0.deviceToken = ppacToken.deviceToken
			$0.previousApiToken = ppacToken.previousApiToken
		}

		let payload = SAP_Internal_Ppdd_ELSOneTimePassword.with {
			$0.otp = otpEls
		}
		self.sendResource = ProtobufSendResource(
			SAP_Internal_Ppdd_ELSOneTimePasswordRequestIOS.with {
				$0.payload = payload
			 $0.authentication = ppacIos
		 }
		)
		
		self.locator = .authorizeOtpEls()
		self.type = .default
		self.receiveResource = JSONReceiveResource<OTPForELSResponsePropertiesReceiveModel>()
		self.trustEvaluation = trustEvaluation
	}
	
	// MARK: - Protocol Resource
	
	typealias Send = ProtobufSendResource<SAP_Internal_Ppdd_ELSOneTimePasswordRequestIOS>
	typealias Receive = JSONReceiveResource<OTPForELSResponsePropertiesReceiveModel>
	typealias CustomError = OTPAuthorizationError

	let trustEvaluation: TrustEvaluating
	
	var locator: Locator
	var type: ServiceType
	var sendResource: ProtobufSendResource<SAP_Internal_Ppdd_ELSOneTimePasswordRequestIOS>
	var receiveResource: JSONReceiveResource<OTPForELSResponsePropertiesReceiveModel>
	
	func customError(
		for error: ServiceError<OTPAuthorizationError>,
		responseBody: Data? = nil
	) -> OTPAuthorizationError? {
		switch error {
		case .transportationError:
			return .noNetworkConnection
		case .unexpectedServerError(let statusCode):
			switch statusCode {
			case 400, 401, 403:
				 return otpAuthorizationFailureHandler(for: responseBody, statusCode: statusCode)
			case 500:
				Log.error("Failed to get authorized OTP - 500 status code", log: .api)
				return .internalServerError
			default:
				Log.error("Failed to authorize OTP - response error", log: .api)
				Log.error(String(statusCode), log: .api)
				return .internalServerError
			}
		default:
			return .invalidResponseError
		}
	}
	
	// MARK: - Private
	
	private func otpAuthorizationFailureHandler(for response: Data?, statusCode: Int) -> OTPAuthorizationError? {
		guard let responseBody = response else {
			Log.error("Failed to get authorized OTP - no 200 status code", log: .api)
			Log.error(String(statusCode), log: .api)
			return .invalidResponseError
		}

		do {
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			let decodedResponse = try decoder.decode(
				OTPResponseProperties.self,
				from: responseBody
			)
			guard let errorCode = decodedResponse.errorCode else {
				Log.error("Failed to get errorCode because it is nil", log: .api)
				return .invalidResponseError
			}

			switch errorCode {
			case .API_TOKEN_ALREADY_ISSUED:
				return .apiTokenAlreadyIssued
			case .API_TOKEN_EXPIRED:
				return .apiTokenExpired
			case .API_TOKEN_QUOTA_EXCEEDED:
				return .apiTokenQuotaExceeded
			case .DEVICE_TOKEN_INVALID:
				return .deviceTokenInvalid
			case .DEVICE_TOKEN_REDEEMED:
				return .deviceTokenRedeemed
			case .DEVICE_TOKEN_SYNTAX_ERROR:
				return .deviceTokenSyntaxError
			default:
				return .otherServerError
			}
		} catch {
			Log.error("Failed to get errorCode because json could not be decoded", log: .api, error: error)
			return .invalidResponseError
		}
	}
}
