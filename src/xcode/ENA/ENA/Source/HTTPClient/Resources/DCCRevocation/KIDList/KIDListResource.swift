//
// 🦠 Corona-Warn-App
//

import Foundation

enum KIDListResourceError: Error {
	case DCC_RL_KID_LIST_SERVER_ERROR
	case DCC_RL_KID_LIST_CLIENT_ERROR
	case DCC_RL_KID_LIST_NO_NETWORK
	case DCC_RL_KID_LIST_INVALID_SIGNATURE
}

struct KIDListResource: Resource {

	init(
		signatureVerifier: SignatureVerification = SignatureVerifier()
	) {
		self.trustEvaluation = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHashData
		)
		self.locator = .kidList
		self.type = .caching([.loadOnlyOnceADay])

#if !RELEASE
		// Debug menu: Force update of revocation list.
		if UserDefaults.standard.bool(forKey: RevocationProvider.keyForceUpdateRevocationList) {
			self.type = .caching()
		}
#endif

		self.sendResource = EmptySendResource()
		self.receiveResource = ProtobufReceiveResource<SAP_Internal_Dgc_RevocationKidList>(
			signatureVerifier: signatureVerifier
		)
	}
	
	// MARK: - Protocol Resource

	typealias Send = EmptySendResource
	typealias Receive = ProtobufReceiveResource<SAP_Internal_Dgc_RevocationKidList>
	
	let trustEvaluation: TrustEvaluating
	let locator: Locator
	var type: ServiceType
	let sendResource: EmptySendResource
	let receiveResource: ProtobufReceiveResource<SAP_Internal_Dgc_RevocationKidList>

#if !RELEASE
	var defaultMockLoadResource: LoadResource? = LoadResource(
		result: .success(SAP_Internal_Dgc_RevocationKidList()),
		willLoadResource: nil
	)
#endif
	
	func customError(for error: ServiceError<KIDListResourceError>, responseBody: Data?) -> KIDListResourceError? {
		switch error {
		case .resourceError(let error):
			if case .signatureVerification = error {
				return .DCC_RL_KID_LIST_INVALID_SIGNATURE
			} else {
				return nil
			}
		case .transportationError:
			return .DCC_RL_KID_LIST_NO_NETWORK
		case .unexpectedServerError(let statusCode):
			return unexpectedServerError(statusCode)
		default:
			return nil
		}
	}
	
	// MARK: - Private
	
	private func unexpectedServerError(
		_ statusCode: Int
	) -> KIDListResourceError? {
		switch statusCode {
		case (400...499):
			return .DCC_RL_KID_LIST_CLIENT_ERROR
		case (500...599):
			return .DCC_RL_KID_LIST_SERVER_ERROR
		default:
			return nil
		}
	}
}
