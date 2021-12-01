//
// 🦠 Corona-Warn-App
//

import Foundation
import ASN1Decoder

public struct JSONWebKey: Codable, Equatable {
    
    public let x5c: [String]
    public let kid: String
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

    public var publicRSASecKey: SecKey? {
        guard let publicKeyData = publicKeyData else {
            return nil
        }

        return SecKeyCreateWithData(
            publicKeyData as NSData,
            [
                kSecAttrKeyType: kSecAttrKeyTypeRSA,
                kSecAttrKeyClass: kSecAttrKeyClassPublic,
            ] as NSDictionary,
            nil
        )
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
    
}
