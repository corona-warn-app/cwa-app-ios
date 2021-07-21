//
// 🦠 Corona-Warn-App
//

import Foundation

public struct DCCSigningCertificate {
    let kid: Data
    let data: Data

    public init(kid: Data, data: Data) {
        self.kid = kid
        self.data = data
    }

}
