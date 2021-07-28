//
// 🦠 Corona-Warn-App
//

import Foundation
import Security
import CryptoKit

public struct DCCSigningCertificate: Codable, Hashable {

    let kid: Data
    let data: Data

    public init(kid: Data, data: Data) {
        self.kid = kid
        self.data = data
    }

    var publicKey: SecKey? {
        if let certificate = SecCertificateCreateWithData(nil, data as CFData),
           let publicKey = SecCertificateCopyKey(certificate) {
            return publicKey
        } else {
            return nil
        }
    }

}
