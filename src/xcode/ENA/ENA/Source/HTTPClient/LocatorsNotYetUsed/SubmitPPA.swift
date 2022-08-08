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
		forceApiTokenHeader: Bool = false
	) -> Locator {
		
		var defaultHeaders = [
			"Content-Type": "application/x-protobuf"
		]
		
		let forceApiHeader = String(forceApiTokenHeader ? 1 : 0)
		#if !RELEASE
		if forceApiTokenHeader {
			defaultHeaders["cwa-ppac-ios-accept-api-token"] = forceApiHeader
		}
		#endif

		return Locator(
			endpoint: .dataDonation,
			paths: ["version", "v1", "ios", "dat"],
			method: .post,
			defaultHeaders: defaultHeaders
		)
	}

}
