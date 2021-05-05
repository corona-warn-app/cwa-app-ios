//
// 🦠 Corona-Warn-App
//

import Foundation

public enum ProofCertificateFetchingError: Error {
    case something
    case general
}

public enum HealthCertificateDecodingError: Error {
    case HC_BASE45_DECODING_FAILED
    case HC_ZLIB_DECOMPRESSION_FAILED
    case HC_COSE_TAG_INVALID
    case HC_COSE_MESSAGE_INVALID
    case HC_CBOR_DECODING_FAILED
    case HC_CWT_NO_ISS
    case HC_CWT_NO_EXP
    case HC_CWT_NO_HCERT
    case HC_CWT_NO_DGC
    case HC_JSON_SCHEMA_INVALID
}
