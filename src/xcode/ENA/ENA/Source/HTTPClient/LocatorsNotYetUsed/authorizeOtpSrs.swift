//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {
    
    // send:	ProtoBuf SAP_Internal_Ppdd_SRSOneTimePasswordRequestIOS
    // receive:	JSON
    // type:	default
    // comment: the endpoint for otp authorization for SRS
    static func authorizeOtpSrs(
		forceApiTokenHeader: Bool = false,
		isFake: Bool
    ) -> Locator {
        let fake = String(isFake ? 1 : 0)
		let forceApiHeader = String(forceApiTokenHeader ? 1 : 0)
		
		#if !RELEASE
		return Locator(
			endpoint: .dataDonation,
			paths: ["version", "v1", "ios", "srs"],
			method: .post,
			defaultHeaders: [
			   "Content-Type": "application/x-protobuf",
			   "cwa-fake": fake,
			   "cwa-ppac-ios-accept-api-token": forceApiHeader
			]
		)
		#else
		return Locator(
			endpoint: .dataDonation,
			paths: ["version", "v1", "ios", "srs"],
			method: .post,
			defaultHeaders: [
				"Content-Type": "application/x-protobuf",
				"cwa-fake": fake,
				"cwa-ppac-ios-accept-api-token": forceApiHeader
			]
		)
		#endif
    }
}
