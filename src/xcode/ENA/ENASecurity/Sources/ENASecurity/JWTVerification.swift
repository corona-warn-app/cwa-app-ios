//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftJWT

public enum JWTVerificationError: Error {
    case JWT_VER_ALG_NOT_SUPPORTED
    case JWT_VER_EMPTY_JWKS
    case JWT_VER_NO_JWK_FOR_KID
    case JWT_VER_NO_KID
    case JWT_VER_SIG_INVALID
}

public struct JWTVerificationClaim: Claims { }

public protocol JWTVerifying {

    func verify(jwtString: String, against jwkSet: [JSONWebKey]) -> Result<Void, JWTVerificationError>

}

public class JWTVerification: JWTVerifying {

    public init() { }

    public func verify(jwtString: String, against jwkSet: [JSONWebKey]) -> Result<Void, JWTVerificationError> {
        // Check for empty jwkSet: if jwkSet is empty, the operation shall abort early with error code JWT_VER_EMPTY_JWKS
        guard !jwkSet.isEmpty else {
            return .failure(.JWT_VER_EMPTY_JWKS)
        }

        // Check alg of JWT: the JWT shall be parsed to extract the JWT header. The alg shall be extracted from the JWT header alg attribute.
        // If there is no alg in the JWT header or if alg is none of ES256, RS256, or PS256, the operation shall abort with error code JWT_VER_ALG_NOT_SUPPORTED.
        guard let jwtObject = try? JWT<JWTVerificationClaim>(jwtString: jwtString),
              let alg = jwtObject.header.alg,
              alg == "ES256" || alg == "RS256" || alg == "PS256" else {
            return .failure(.JWT_VER_ALG_NOT_SUPPORTED)
        }

        // Extract kid from JWT: the JWT shall be parsed to extract the JWT header. The kid shall be extracted from the JWT header from the kid attribute.
        // If there is no kid in the JWT header, the operation shall abort with error code JWT_VER_NO_KID.
        guard let kid = jwtObject.header.kid else {
            return .failure(.JWT_VER_NO_KID)
        }

        // Filter jwkSet by kid: the jwkSet shall be filtered for those entries where jwk.kid matches the kid from the JWT header.
        // Note that there can be multiple JWKs with the same KID.
        let filteredJwkSet = jwkSet.filter {
            $0.kid == kid
        }

        // Check for empty jwkSet: if the filtered jwkSet is empty, the operation shall abort with error code JWT_VER_NO_JWK_FOR_KID.
        guard !filteredJwkSet.isEmpty else {
            return .failure(.JWT_VER_NO_JWK_FOR_KID)
        }

        // Verify signature: the entries of jwkSet shall be used sequentially to check the signature as per Verifying the Signature of a JWT with a Public Key.
        let passedJwk = filteredJwkSet.first {
            guard let pemData = $0.pemUtf8Data else {
                return false
            }

            switch verify(jwtString: jwtString, against: pemData, and: $0.alg) {
            case .success:
                return true
            case .failure:
                return false
            }
        }

        if passedJwk != nil {
            return .success(())
        } else {
            return .failure(.JWT_VER_SIG_INVALID)
        }
    }

    public func verify(jwtString: String, against publicKey: Data, and algorithm: String) -> Result<Void, JWTVerificationError> {
        let verifier: JWTVerifier
        switch algorithm {
        case "ES256":
            verifier = JWTVerifier.es256(publicKey: publicKey)
        case "RS256":
            verifier = JWTVerifier.rs256(publicKey: publicKey)
        case "PS256":
            verifier = JWTVerifier.ps256(publicKey: publicKey)
        default:
            return .failure(.JWT_VER_ALG_NOT_SUPPORTED)
        }

        if JWT<JWTVerificationClaim>.verify(jwtString, using: verifier) {
            return .success(())
        } else {
            return .failure(.JWT_VER_SIG_INVALID)
        }
    }
}
