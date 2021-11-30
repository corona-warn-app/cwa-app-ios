//
// 🦠 Corona-Warn-App
//

import Foundation
import ASN1Decoder

public struct JSONWebKey: Codable, Equatable {
    
    public let x5c: [String]
    let kid: String
    let alg: String
    let use: String

    public var publicKey: X509PublicKey? {
        guard let x509String = x5c.first,
              let x509Data = Data(base64Encoded: x509String),
              let x509Certificate = try? X509Certificate(data: x509Data) else {
            return nil
        }
        return x509Certificate.publicKey
    }

    public var publicKeyData: Data? {
        guard let x509String = x5c.first,
              let x509Data = Data(base64Encoded: x509String),
              let x509Certificate = try? X509Certificate(data: x509Data) else {
            return nil
        }
        return x509Certificate.publicKey?.derEncodedKey
    }

    public var publicKeyDERBase64: String? {
        guard let x509String = x5c.first,
              let x509Data = Data(base64Encoded: x509String),
              let x509Certificate = try? X509Certificate(data: x509Data) else {
            return nil
        }
        return x509Certificate.publicKey?.derEncodedKey?.base64EncodedString()
    }

    public var pemUtf8Data: Data? {
        guard let base64String = publicKeyDERBase64 else {
            return nil
        }
        let pemString = "-----BEGIN PUBLIC KEY-----\(base64String)-----END PUBLIC KEY-----"
        guard let pemData = pemString.data(using: .utf8) else {
            return nil
        }
        return pemData
    }
    
    public static func fake(
        x5c: [String] = ["fake"],
        kid: String = "fake",
        alg: String = "fake",
        use: String = "fake"
    ) -> JSONWebKey {
        JSONWebKey(x5c: x5c, kid: kid, alg: alg, use: use)
    }
}
