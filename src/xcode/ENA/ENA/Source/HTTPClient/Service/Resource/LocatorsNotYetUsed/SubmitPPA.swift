//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	ProtoBuf SAP_Internal_Ppdd_PPADataRequestIOS
	// receive: Empty
	// type:	default
	// comment:	Custom error handling required
	static func submitPPA(
		payload: SAP_Internal_Ppdd_PPADataIOS,
		forceApiTokenHeader: Bool = false,
		isFake: Bool
	) -> Locator {
		let fake = String(isFake ? 1 : 0)
		let forceApiHeader = String(forceApiTokenHeader ? 1 : 0)
		return Locator(
			endpoint: .dataDonation,
			paths: ["version", "v1", "ios", "dat"],
			method: .post,
			defaultHeaders: [
				"Content-Type": "application/x-protobuf",
				"cwa-ppac-ios-accept-api-token": forceApiHeader,
				"cwa-fake": fake
			]
		)
	}

}
