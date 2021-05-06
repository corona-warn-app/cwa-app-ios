//
// 🦠 Corona-Warn-App
//

import Foundation

public enum ProofCertificateFetchingError: Error {
    case something
    case general
}

public enum CertificateDecodingError: Error {
    case HC_BASE45_DECODING_FAILED
    case HC_ZLIB_DECOMPRESSION_FAILED
    case HC_COSE_TAG_INVALID
    case HC_COSE_MESSAGE_INVALID
    case HC_CBOR_DECODING_FAILED
    // HC_CWT_NO_ISS
    case HC_CBORWEBTOKEN_NO_ISSUER
    // HC_CWT_NO_EXP
    case HC_CBORWEBTOKEN_NO_EXPIRATIONTIME
    // HC_CWT_NO_HCERT
    case HC_CBORWEBTOKEN_NO_HEALTHCERTIFICATE
    // HC_CWT_NO_DGC
    case HC_CBORWEBTOKEN_NO_DIGITALGREENCERTIFICATE
}
