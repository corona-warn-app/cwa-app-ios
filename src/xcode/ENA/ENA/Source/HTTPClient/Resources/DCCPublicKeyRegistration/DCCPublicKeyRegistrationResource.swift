//
// 🦠 Corona-Warn-App
//

import Foundation

struct DCCPublicKeyRegistrationResource: Resource {

	// MARK: - Init

	init(
		isFake: Bool = false,
		sendModel: DCCPublicKeyRegistrationSendModel,
		trustEvaluation: TrustEvaluating = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHashData
		)
	) {
		self.locator = .registrationToken(isFake: isFake)
		self.type = .default
		self.sendResource = PaddingJSONSendResource<DCCPublicKeyRegistrationSendModel>(sendModel)
		self.receiveResource = EmptyReceiveResource()
		self.trustEvaluation = trustEvaluation
	}

	// MARK: - Protocol Resource

	typealias Send = PaddingJSONSendResource<DCCPublicKeyRegistrationSendModel>
	typealias Receive = EmptyReceiveResource
	typealias CustomError = DCCPublicKeyRegistrationError

	let trustEvaluation: TrustEvaluating

	var locator: Locator
	var type: ServiceType
	var sendResource: PaddingJSONSendResource<DCCPublicKeyRegistrationSendModel>
	var receiveResource: EmptyReceiveResource

#if !RELEASE
	var defaultMockLoadResource: LoadResource? = LoadResource(
		result: .success(()),
		willLoadResource: nil
	)
#endif
	
	func customError(
		for error: ServiceError<DCCPublicKeyRegistrationError>,
		responseBody: Data? = nil
	) -> DCCPublicKeyRegistrationError? {
		switch error {
		case .unexpectedServerError(let statusCode):
			switch statusCode {
			case 400:
				return .badRequest
			case 403:
				return .tokenNotAllowed
			case 404:
				return .tokenDoesNotExist
			case 409:
				return .tokenAlreadyAssigned
			case 500:
				return .internalServerError
			default:
				return .unhandledResponse(statusCode)
			}
		case .transportationError:
			return .noNetworkConnection
		default:
			return nil
		}
	}

}
