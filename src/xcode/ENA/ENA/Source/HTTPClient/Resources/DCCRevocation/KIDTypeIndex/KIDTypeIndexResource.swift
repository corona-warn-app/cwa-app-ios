//
// 🦠 Corona-Warn-App
//

import Foundation

enum KIDTypeIndexResourceError: Error {
	case DCC_RL_KID_LIST_SERVER_ERROR
	case DCC_RL_KID_LIST_CLIENT_ERROR
	case DCC_RL_KID_LIST_NO_NETWORK
	case DCC_RL_KID_LIST_INVALID_SIGNATURE
}

struct KIDTypeIndexResource: Resource {

	init(
		kid: String,
		hashType: String
	) {
		self.trustEvaluation = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHashData
		)
		self.locator = Locator(kid: kid, hashType: hashType)
		self.type = .caching()
		self.sendResource = EmptySendResource()
		self.receiveResource = ProtobufReceiveResource<SAP_Internal_Dgc_RevocationKidTypeIndex>()
	}
	
	// MARK: - Protocol Resource

	typealias Send = EmptySendResource
	typealias Receive = ProtobufReceiveResource<SAP_Internal_Dgc_RevocationKidTypeIndex>
	typealias CustomError = Error // no custom error here at the moment

	let trustEvaluation: TrustEvaluating
	let locator: Locator
	let type: ServiceType
	let sendResource: EmptySendResource
	let receiveResource: ProtobufReceiveResource<SAP_Internal_Dgc_RevocationKidTypeIndex>
	
}
