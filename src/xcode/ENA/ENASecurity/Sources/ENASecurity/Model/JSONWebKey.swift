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

    var publicKey: X509PublicKey? {
        guard let x5cData = Data(base64Encoded: x5c),
              let x509Certificate = try? X509Certificate(data: x5cData) else {
            return nil
        }
        return x509Certificate.publicKey
    }

    var publicKeyData: Data? {
        guard let x5cData = Data(base64Encoded: x5c),
              let x509Certificate = try? X509Certificate(data: x5cData) else {
            return nil
        }
        return x509Certificate.publicKey?.derEncodedKey
    }
}
