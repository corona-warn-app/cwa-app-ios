//
// 🦠 Corona-Warn-App
//

import Foundation
import ASN1Decoder

struct JSONWebKey: Codable {
    let x5c: String
    let kid: String
    let alg: String
    let use: String

    func publicKey() -> X509PublicKey? {
        guard let x5xData = Data(base64Encoded: x5c),
              let x509Certificate = try? X509Certificate(data: x5xData) else {
            return nil
        }
        return x509Certificate.publicKey
    }
}
