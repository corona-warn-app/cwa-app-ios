//
// 🦠 Corona-Warn-App
//

import Foundation

public enum DCCSignatureVerificationError: Error, Equatable {
    case HC_CBOR_DECODING_FAILED(CertificateDecodingError)
    case HC_COSE_PH_INVALID
    case HC_COSE_NO_SIGN1
    case HC_COSE_NO_ALG
    case HC_COSE_UNKNOWN_ALG
    case HC_COSE_ECDSA_SPLITTING_FAILED
    case HC_DSC_NO_MATCH
    case HC_DSC_NOT_READABLE
    case HC_DSC_NOT_YET_VALID
    case HC_DSC_EXPIRED
    case HC_DSC_OID_MISMATCH_TC
    case HC_DSC_OID_MISMATCH_VC
    case HC_DSC_OID_MISMATCH_RC
}
