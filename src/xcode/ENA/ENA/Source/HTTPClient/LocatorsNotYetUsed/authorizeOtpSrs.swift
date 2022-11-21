//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {
    
    // send:	ProtoBuf SAP_Internal_Ppdd_SRSOneTimePasswordRequestIOS
    // receive:	JSON
    // type:	default
    // comment:
    static func authorizeOtpSrs(
        isFake: Bool
    ) -> Locator {
        let fake = String(isFake ? 1 : 0)
        return Locator(
            endpoint: .dataDonation,
            paths: ["version", "v1", "ios", "srs"],
            method: .post,
            defaultHeaders: [
                "Content-Type": "application/x-protobuf",
                "cwa-fake": fake
            ]
        )
    }
}
