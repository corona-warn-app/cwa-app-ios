//
// 🦠 Corona-Warn-App
//

import Foundation

struct OTPAuthorizationForSRSResource: Resource {
	
	// MARK: - Init
	
	init(
		otpSRS: String,
		isFake: Bool = false,
		ppacToken: PPACToken,
		trustEvaluation: TrustEvaluating = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHashData
		)
	) {
		let ppacIos = SAP_Internal_Ppdd_PPACIOS.with {
			$0.apiToken = ppacToken.apiToken
			$0.deviceToken = ppacToken.deviceToken
		}
		let payload = SAP_Internal_Ppdd_SRSOneTimePassword.with {
			$0.otp = otpSRS
		}
		self.sendResource = ProtobufSendResource(
			SAP_Internal_Ppdd_SRSOneTimePasswordRequestIOS.with {
				// to.do padding
				$0.payload = payload
				$0.authentication = ppacIos
			}
		)
		
		self.locator = .authorizeOtpSrs(isFake: isFake)
		self.type = .default
		self.receiveResource = JSONReceiveResource<OTPResponsePropertiesReceiveModel>()
		self.trustEvaluation = trustEvaluation
	}
	
	// MARK: - Protocol Resource
	
	typealias Send = ProtobufSendResource<SAP_Internal_Ppdd_SRSOneTimePasswordRequestIOS>
	typealias Receive = JSONReceiveResource<OTPResponsePropertiesReceiveModel>
	typealias CustomError = OTPAuthorizationError
	
	let trustEvaluation: TrustEvaluating
	
	var locator: Locator
	var type: ServiceType
	var sendResource: ProtobufSendResource<SAP_Internal_Ppdd_SRSOneTimePasswordRequestIOS>
	var receiveResource: JSONReceiveResource<OTPResponsePropertiesReceiveModel>
	
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
				return .otherServerError
			default:
				Log.error("Failed to authorize OTP - response error: \(statusCode)", log: .api)
				return .otherServerError
			}
		default:
			return .otherServerError
		}
	}
	
	// MARK: - Private
	
	private func otpAuthorizationFailureHandler(for response: Data?, statusCode: Int) -> OTPAuthorizationError? {
		guard let responseBody = response else {
			Log.error("Failed to get authorized OTP - no 200 status code: \(statusCode)", log: .api)
			return .otherServerError
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
				return .otherServerError
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
			return .otherServerError
		}
	}
}
