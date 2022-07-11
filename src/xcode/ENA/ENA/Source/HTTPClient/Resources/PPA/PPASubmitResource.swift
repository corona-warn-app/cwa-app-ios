//
// 🦠 Corona-Warn-App
//

import Foundation

enum PPASubmitResourceError: Error, Equatable {
	case submissionInProgress
	case generalError
	case urlCreationError
	case responseError(Int)
	case jsonError
	case serverError(PPAServerErrorCode)
	case ppacError(PPACError)
	case appResetError
	case onboardingError
	case submissionTimeAmountUndercutError
	case probibilityError
	case userConsentError
}

struct PPASubmitResource: Resource {
	
	init(
		isFake: Bool = false,
		forceApiTokenHeader: Bool = false,
		payload: SAP_Internal_Ppdd_PPADataIOS,
		ppacToken: PPACToken,
		trustEvaluation: TrustEvaluating = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHashData
		)
	) {
		let ppacIos = SAP_Internal_Ppdd_PPACIOS.with {
			$0.apiToken = ppacToken.apiToken
			$0.deviceToken = ppacToken.deviceToken
		}
		self.sendResource = ProtobufSendResource(
			SAP_Internal_Ppdd_PPADataRequestIOS.with {
				$0.payload = payload
				$0.authentication = ppacIos
			}
		)
		self.locator = .submitPPA(payload: payload, isFake: isFake)
		self.type = .default
		self.receiveResource = EmptyReceiveResource()
		self.trustEvaluation = trustEvaluation
	}
	
	// MARK: - Protocol Resource

	let trustEvaluation: TrustEvaluating

	var locator: Locator
	var type: ServiceType
	var sendResource: ProtobufSendResource<SAP_Internal_Ppdd_PPADataRequestIOS>
	var receiveResource: EmptyReceiveResource

	func customError(for error: ServiceError<PPASubmitResourceError>, responseBody: Data?) -> PPASubmitResourceError? {
		switch error {
		case .unexpectedServerError(let statusCode):
			switch statusCode {
			case 400, 401, 403, 429:
				guard let responseBody = responseBody else {
					Log.error("Error in response body: \(statusCode)", log: .api)
					return .responseError(statusCode)
				}
				do {
					let decodedResponse = try JSONDecoder().decode(
						PPACResponse.self,
						from: responseBody
					)
					guard let errorCode = decodedResponse.errorCode else {
						Log.error("Error at converting decodedResponse to PPACResponse", log: .api)
						return .jsonError
					}
					Log.error("Server error at submitting anatlytics data", log: .api)
					return .serverError(errorCode)
				} catch {
					Log.error("Error at decoding server response json", log: .api, error: error)
					return .jsonError
				}
			case 500:
				Log.error("Server error at submitting anatlytics data", log: .api)
				return .responseError(500)
				
			default:
				Log.error("Error in response body: \(statusCode)", log: .api)
				return .responseError(statusCode)
			}
		default:
			return nil
		}
	}
}
