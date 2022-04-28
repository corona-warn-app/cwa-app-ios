//
// 🦠 Corona-Warn-App
//

import Foundation

struct DigitalCovid19CertificateResource: Resource {

	// MARK: - Init

	init(
		isFake: Bool = false,
		sendModel: DigitalCovid19CertificateSendModel,
		trustEvaluation: TrustEvaluating = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHashData
		)
	) {
		self.locator = .registrationToken(isFake: isFake)
		self.type = .default
		self.sendResource = PaddingJSONSendResource<DigitalCovid19CertificateSendModel>(sendModel)
		self.receiveResource = JSONReceiveResource<DigitalCovid19CertificateReceiveModel>()
		self.trustEvaluation = trustEvaluation
	}

	// MARK: - Protocol Resource

	typealias Send = PaddingJSONSendResource<DigitalCovid19CertificateSendModel>
	typealias Receive = JSONReceiveResource<DigitalCovid19CertificateReceiveModel>
	typealias CustomError = DigitalCovid19CertificateError

	let trustEvaluation: TrustEvaluating

	var locator: Locator
	var type: ServiceType
	var sendResource: PaddingJSONSendResource<DigitalCovid19CertificateSendModel>
	var receiveResource: JSONReceiveResource<DigitalCovid19CertificateReceiveModel>

#if !RELEASE
	var defaultMockLoadResource: LoadResource? = LoadResource(
		result: .success((DigitalCovid19CertificateReceiveModel(dek: "dataEncryptionKey", dcc: "coseObject"))),
		willLoadResource: nil
	)
#endif

	// swiftlint:disable cyclomatic_complexity
	func customError(
		for error: ServiceError<DigitalCovid19CertificateError>,
		responseBody: Data? = nil
	) -> DigitalCovid19CertificateError? {
		switch error {
		case .unexpectedServerError(let statusCode):
			switch statusCode {
			case 202:
				Log.error("HTTP error code 202. DCC is pending.", log: .api)
				return .dccPending
			case 400:
				Log.error("HTTP error code 400. Bad Request. Perhaps the registration token is wrong formatted?", log: .api)
				return .badRequest
			case 404:
				Log.error("HTTP error code 404. RegistrationToken does not exist.", log: .api)
				return .tokenDoesNotExist
			case 410:
				Log.error("HTTP error code 410. DCC is already cleaned up.", log: .api)
				return .dccAlreadyCleanedUp
			case 412:
				Log.error("HTTP error code 412. Test result not yet received.", log: .api)
				return .testResultNotYetReceived
			case 500:
				Log.error("HTTP error code 500. Internal server error.", log: .api)
				guard let responseBody = responseBody else {
					Log.error("Error in code 500 response body: \(statusCode)", log: .api)
					return .unhandledResponse(statusCode)
				}
				do {
					let decodedResponse = try JSONDecoder().decode(
						DCC500Response.self,
						from: responseBody
					)
					return .internalServerError(reason: decodedResponse.reason)
				} catch {
					Log.error("Failed to decode code 500 response json", log: .api, error: error)
					return .internalServerError(reason: nil)
				}
			default:
				return .unhandledResponse(statusCode)
			}
		case .transportationError:
			return .noNetworkConnection
		default:
			return .defaultServerError(error)
		}
	}

}
