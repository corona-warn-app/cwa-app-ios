//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	ProtoBuf SAP_Internal_Ppdd_ELSOneTimePasswordRequestIOS
	// receive:	JSON
	// type:	default
	// comment:
	static func authorizeOtpEls(
		forceApiTokenHeader: Bool = false,
		isFake: Bool
	) -> Locator {
		let fake = String(isFake ? 1 : 0)
		let forceApiHeader = String(forceApiTokenHeader ? 1 : 0)
		return Locator(
			endpoint: .dataDonation,
			paths: ["version", "v1", "ios", "els"],
			method: .post,
			defaultHeaders: [
				"cwa-fake": fake,
				"cwa-ppac-ios-accept-api-token": forceApiHeader
			]
		)
	}

}
