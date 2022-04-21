//
// 🦠 Corona-Warn-App
//

import Foundation

struct KIDTypeIndexResource: Resource {

	init(
		kid: String,
		hashType: String
	) {
		self.trustEvaluation = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHashData
		)
		self.locator = Locator(kid: kid, hashType: hashType)
		self.type = .caching([.loadOnlyOnceADay])

#if !RELEASE
		// Debug menu: Force update of revocation list.
		if UserDefaults.standard.bool(forKey: RevocationProvider.keyForceUpdateRevocationList) {
			self.type = .caching()
		}
#endif

		self.sendResource = EmptySendResource()
		self.receiveResource = ProtobufReceiveResource<SAP_Internal_Dgc_RevocationKidTypeIndex>()
	}
	
	// MARK: - Protocol Resource

	typealias Send = EmptySendResource
	typealias Receive = ProtobufReceiveResource<SAP_Internal_Dgc_RevocationKidTypeIndex>
	typealias CustomError = Error // no custom error here at the moment

	let trustEvaluation: TrustEvaluating
	let locator: Locator
	var type: ServiceType
	let sendResource: EmptySendResource
	let receiveResource: ProtobufReceiveResource<SAP_Internal_Dgc_RevocationKidTypeIndex>
	
}
