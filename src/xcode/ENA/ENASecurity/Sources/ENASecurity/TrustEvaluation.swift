//
// 🦠 Corona-Warn-App
//

import Foundation
import CommonCrypto
import CryptoKit
import ASN1Decoder

enum CertificateChainCheckError: Error {
    case CERT_CHAIN_EMTPY
    case CERT_PIN_NO_JWK_FOR_KID
    case CERT_PIN_MISMATCH
}

class TrustEvaluation {

    func check(certificateChain: [Data], against jwkSet: [Data]) -> Result<Void, CertificateChainCheckError> {

        // Extract leafCertificate: the leafCertificate shall be extracted from the certificateChain. This is typically the first certificate of the chain.
        guard let leafCertificateData = certificateChain.first else {
            return .failure(.CERT_CHAIN_EMTPY)
        }

        // Determine requiredKid: the requiredKid (a string) shall be determined by taking the first 8 bytes of the SHA-256 fingerprint of the leafCertificate and encoding it with base64.
        let requiredKid = leafCertificateData.keyIdentifier

        // Find requiredJwkSet: the requiredJwkSet shall be set to the array of entries from jwkSet where kid matches the requiredKid.
        let requiredJwkSet = jwkSet
            .compactMap { jsonWebKeyData -> JSONWebKey? in
                guard let jsonWebKey = try? JSONDecoder().decode(JSONWebKey.self, from: jsonWebKeyData) else {
                    return nil
                }
                return jsonWebKey
            }
            .filter { jsonWebKey in
                return jsonWebKey.kid == requiredKid
            }

        // If requiredJwkSet is empty, the operation shall abort with error code CERT_PIN_NO_JWK_FOR_KID.
        guard !requiredJwkSet.isEmpty else {
            return .failure(.CERT_PIN_NO_JWK_FOR_KID)
        }

        // Find requiredCertificates: the requiredCertificates shall be set by mapping each entry in requiredJwkSet to their native x509 certificate object by parsing the x5c attribute.
        // Note that x5c is a base64-encoded string.
        let requiredCertificates = requiredJwkSet.compactMap { jsonWebKey -> Data? in
            Data(base64Encoded: jsonWebKey.x5x)
        }

        // Find requiredFingerprints: the requiredFingerprints shall be set by mapping each entry in requiredCertificates to their respective SHA-256 fingerprint.
        let requiredFingerprints = requiredCertificates.compactMap { certificate -> String in
            return certificate.fingerprint
        }

        // Compare fingerprints: if the SHA-256 fingerprints of leafCertificate is not included in requiredFingerprints, the operation shall abort with error code CERT_PIN_MISMATCH.
        if requiredFingerprints.contains(leafCertificateData.fingerprint) {
            return .success(())
        } else {
            return .failure(.CERT_PIN_MISMATCH)
        }
    }

}

extension Data {

    func sha256() -> Data {
        // via https://www.agnosticdev.com/content/how-use-commoncrypto-apis-swift-5

        // #define CC_SHA256_DIGEST_LENGTH     32
        // Creates an array of unsigned 8 bit integers that contains 32 zeros
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))

        // CC_SHA256 performs digest calculation and places the result in the caller-supplied buffer for digest (md)
        // Takes the strData referenced value (const unsigned char *d) and hashes it into a reference to the digest parameter.
        _ = self.withUnsafeBytes {
            // CommonCrypto
            // extern unsigned char *CC_SHA256(const void *data, CC_LONG len, unsigned char *md)  -|
            // OpenSSL                                                                             |
            // unsigned char *SHA256(const unsigned char *d, size_t n, unsigned char *md)        <-|
            CC_SHA256($0.baseAddress, UInt32(self.count), &digest)
        }

        return Data(digest)
    }

    var fingerprint: String {
        sha256().base64EncodedString()
    }

    var keyIdentifier: String {
        sha256().subdata(in: 0..<8).base64EncodedString()
    }
}
