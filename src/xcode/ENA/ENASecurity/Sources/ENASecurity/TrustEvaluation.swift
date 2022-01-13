//
// 🦠 Corona-Warn-App
//

import Foundation

public enum TrustEvaluationError: Error {
    case CERT_CHAIN_EMTPY
    case CERT_PIN_NO_JWK_FOR_KID
    case CERT_PIN_MISMATCH
    case CERT_PIN_HOST_MISMATCH
}

public class TrustEvaluation {

    // MARK: - Init

    public init() {}

    // MARK: - Public

    public func check(trust: SecTrust, against jwkSet: [JSONWebKey], logMessage: ((String) -> Void)?) -> Result<Void, TrustEvaluationError> {
        // Extract leafCertificate: the leafCertificate shall be extracted from the certificateChain. This is typically the first certificate of the chain.
        if let serverCertificate = SecTrustGetCertificateAtIndex(trust, 0),
           let serverCertificateData = SecCertificateCopyData(serverCertificate) as Data? {

            return check(serverKeyData: serverCertificateData, against: jwkSet, logMessage: logMessage)
        } else {
            return .failure(.CERT_CHAIN_EMTPY)
        }
    }

    public func check(serverKeyData: Data, against jwkSet: [JSONWebKey], logMessage: ((String) -> Void)?) -> Result<Void, TrustEvaluationError> {
        // Determine requiredKid: the requiredKid (a string) shall be determined by taking the first 8 bytes of the SHA-256 fingerprint of the leafCertificate and encoding it with base64.
        
        let requiredKid = serverKeyData.keyIdentifier
        
        logMessage?("Server certificate key identifier (requiredKid): \(requiredKid)")

        // Find requiredJwkSet: the requiredJwkSet shall be set to the array of entries from jwkSet where kid matches the requiredKid.
        let requiredJwkSet = jwkSet
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
            guard let x509String = jsonWebKey.x5c.first else {
                return nil
            }
            return Data(base64Encoded: x509String)
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
    
    public func checkServerCertificateAgainstAllowlist(
        hostname: String,
        trust: SecTrust,
        allowList: [ValidationServiceAllowlistEntry]
    ) -> Result<Void, TrustEvaluationError> {
                
        guard let serverCertificate = SecTrustGetCertificateAtIndex(trust, 0),
           let leafCertificate = SecCertificateCopyData(serverCertificate) as Data? else {
            return .failure(.CERT_CHAIN_EMTPY)
        }

        // Compare fingerprints: if the SHA-256 fingerprints of leafCertificate is not included in requiredFingerprints, the operation shall abort with error code CERT_PIN_MISMATCH.
        let leafFingerprint = leafCertificate.sha256().base64EncodedString()
        if !allowList.contains(where: {
            $0.fingerprint256 == leafFingerprint
        }) {
            return .failure(.CERT_PIN_MISMATCH)
        }
        
        let requiredHostnames: [String] = allowList.compactMap({
            $0.fingerprint256 == leafFingerprint ? $0.hostname : nil
        })
        if !requiredHostnames.contains(where: {
            $0 == hostname
        }) {
            return .failure(.CERT_PIN_HOST_MISMATCH)
        }
        return .success(())
    }

}
