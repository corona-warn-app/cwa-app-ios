//
// 🦠 Corona-Warn-App
//

import Foundation
import ASN1Decoder

struct JSONWebKey: Codable {
    let x5c: [String]
    let kid: String
    let alg: String
    let use: String

    var publicKey: X509PublicKey? {
        guard let x509String = x5c.first,
              let x509Data = Data(base64Encoded: x509String),
              let x509Certificate = try? X509Certificate(data: x509Data) else {
            return nil
        }
        return x509Certificate.publicKey
    }

    var publicKeyData: Data? {
        guard let x509String = x5c.first,
              let x509Data = Data(base64Encoded: x509String),
              let x509Certificate = try? X509Certificate(data: x509Data) else {
            return nil
        }
        return x509Certificate.publicKey?.derEncodedKey
    }
}
