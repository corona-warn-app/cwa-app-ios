//
// 🦠 Corona-Warn-App
//

import Foundation
import JSONSchema

// Makes ValidationError represantable with "print()".
extension ValidationError: CustomStringConvertible {}

public enum JSONSchemaValidationError: Error {
    case FILE_NOT_FOUND
    case DECODING_FAILED
    case VALIDATION_FAILED(Error)
    case VALIDATION_RESULT_FAILED([ValidationError])
}

public enum CertificateDecodingError: Error {

    case HC_BASE45_DECODING_FAILED(Error?)
    case HC_BASE45_ENCODING_FAILED
    case HC_ZLIB_DECOMPRESSION_FAILED(Error)
    case HC_ZLIB_COMPRESSION_FAILED
    case HC_COSE_TAG_INVALID
    case HC_COSE_MESSAGE_INVALID
    case HC_CBOR_DECODING_FAILED(Error)
    // HC_CWT_NO_ISS
    case HC_CBORWEBTOKEN_NO_ISSUER
    // HC_CWT_NO_EXP
    case HC_CBORWEBTOKEN_NO_EXPIRATIONTIME
    // HC_CWT_NO_HCERT
    case HC_CBORWEBTOKEN_NO_HEALTHCERTIFICATE
    // HC_CWT_NO_DGC
    case HC_CBORWEBTOKEN_NO_DIGITALGREENCERTIFICATE
    case HC_JSON_SCHEMA_INVALID(JSONSchemaValidationError)
    case HC_PREFIX_INVALID
    case AES_DECRYPTION_FAILED
}
