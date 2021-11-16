//
// 🦠 Corona-Warn-App
//

import Foundation

public enum TrustEvaluationError: Error {
    case CERT_CHAIN_EMTPY
    case CERT_PIN_NO_JWK_FOR_KID
    case CERT_PIN_MISMATCH
}

public class TrustEvaluation {

    // MARK: - Init

    public init() {}

    // MARK: - Public

    public func check(trust: SecTrust, against jwkSet: [Data]) -> Result<Void, TrustEvaluationError> {
        // Extract leafCertificate: the leafCertificate shall be extracted from the certificateChain. This is typically the first certificate of the chain.
        if let serverCertificate = SecTrustGetCertificateAtIndex(trust, SecTrustGetCertificateCount(trust) - 1),
           let serverPublicKey = SecCertificateCopyKey(serverCertificate),
           let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey, nil) as Data? {

            return check(serverKeyData: serverPublicKeyData, against: jwkSet)
        } else {
            return .failure(.CERT_CHAIN_EMTPY)
        }
    }

    // MARK: - Internal

    func check(serverKeyData: Data, against jwkSet: [Data]) -> Result<Void, TrustEvaluationError> {
        // Determine requiredKid: the requiredKid (a string) shall be determined by taking the first 8 bytes of the SHA-256 fingerprint of the leafCertificate and encoding it with base64.
        let requiredKid = serverKeyData.keyIdentifier

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
        if requiredFingerprints.contains(serverKeyData.fingerprint) {
            return .success(())
        } else {
            return .failure(.CERT_PIN_MISMATCH)
        }
    }

}
