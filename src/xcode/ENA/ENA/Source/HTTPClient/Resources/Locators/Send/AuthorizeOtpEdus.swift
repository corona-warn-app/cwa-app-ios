//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	Protobuf SAP_Internal_Ppdd_EDUSOneTimePasswordRequestIOS
	// receive:	JSON
	// type:	default
	// comment:
	static func authorizeOtpEdus(
		forceApiTokenHeader: Bool = false,
		isFake: Bool
	) -> Locator {
		let fake = String(isFake ? 1 : 0)
		let forceApiHeader = String(forceApiTokenHeader ? 1 : 0)
		return Locator(
			endpoint: .dataDonation,
			paths: ["version", "v1", "ios", "otp"],
			method: .post,
			defaultHeaders: [
				"cwa-fake": fake,
				"cwa-ppac-ios-accept-api-token": forceApiHeader
			]
		)
	}

}
