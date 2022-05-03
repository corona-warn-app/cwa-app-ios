//
// 🦠 Corona-Warn-App
//

import Foundation
import JSONSchema

// CustomStringConvertible makes ValidationError represantable with "print()".
extension ValidationError: CustomStringConvertible, Equatable {

    // MARK: - Protocol Equatable

    public static func == (lhs: ValidationError, rhs: ValidationError) -> Bool {
        return lhs.description == rhs.description
    }
}

public enum JSONSchemaValidationError: Error, Equatable {

    case FILE_NOT_FOUND
    case DECODING_FAILED
    case VALIDATION_FAILED(Error)
    case VALIDATION_RESULT_FAILED([ValidationError])

    // MARK: - Protocol Equatable

    public static func == (lhs: JSONSchemaValidationError, rhs: JSONSchemaValidationError) -> Bool {
        switch (lhs, rhs) {
        case (.FILE_NOT_FOUND, .FILE_NOT_FOUND):
            return true
        case (.DECODING_FAILED, .DECODING_FAILED):
            return true
        case let (.VALIDATION_FAILED(lhsError), .VALIDATION_FAILED(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.VALIDATION_RESULT_FAILED(lhsError), .VALIDATION_RESULT_FAILED(rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

public enum CertificateDecodingError: Error, Equatable {

    case HC_BASE45_DECODING_FAILED(Error?)
    case HC_BASE45_ENCODING_FAILED
    case HC_ZLIB_DECOMPRESSION_FAILED(Error)
    case HC_ZLIB_COMPRESSION_FAILED
    case HC_COSE_TAG_OR_ARRAY_INVALID
    case HC_COSE_MESSAGE_INVALID
    case HC_COSE_NO_KEYIDENTIFIER
    case HC_COSE_NO_SIGN
    case HC_COSE_PH_INVALID
    case HC_COSE_UNKNOWN_ALG
    case HC_COSE_NO_ALG
    case HC_CBOR_DECODING_FAILED(Error?)
    case HC_CBOR_TRIMMING_FAILED
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

    // MARK: - Protocol Equatable

    // swiftlint:disable cyclomatic_complexity
    public static func == (lhs: CertificateDecodingError, rhs: CertificateDecodingError) -> Bool {
        switch (lhs, rhs) {
        case let (.HC_BASE45_DECODING_FAILED(lhsError), .HC_BASE45_DECODING_FAILED(rhsError)):
            return lhsError?.localizedDescription == rhsError?.localizedDescription
        case (.HC_BASE45_ENCODING_FAILED, .HC_BASE45_ENCODING_FAILED):
            return true
        case let (.HC_ZLIB_DECOMPRESSION_FAILED(lhsError), .HC_ZLIB_DECOMPRESSION_FAILED(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.HC_ZLIB_COMPRESSION_FAILED, .HC_ZLIB_COMPRESSION_FAILED):
            return true
        case (.HC_COSE_TAG_OR_ARRAY_INVALID, .HC_COSE_TAG_OR_ARRAY_INVALID):
            return true
        case (.HC_COSE_MESSAGE_INVALID, .HC_COSE_MESSAGE_INVALID):
            return true
        case (.HC_COSE_NO_KEYIDENTIFIER, .HC_COSE_NO_KEYIDENTIFIER):
            return true
        case let (.HC_CBOR_DECODING_FAILED(lhsError), .HC_CBOR_DECODING_FAILED(rhsError)):
            return lhsError?.localizedDescription == rhsError?.localizedDescription
        case (.HC_CBORWEBTOKEN_NO_ISSUER, .HC_CBORWEBTOKEN_NO_ISSUER):
            return true
        case (.HC_CBORWEBTOKEN_NO_EXPIRATIONTIME, .HC_CBORWEBTOKEN_NO_EXPIRATIONTIME):
            return true
        case (.HC_CBORWEBTOKEN_NO_HEALTHCERTIFICATE, .HC_CBORWEBTOKEN_NO_HEALTHCERTIFICATE):
            return true
        case (.HC_CBORWEBTOKEN_NO_DIGITALGREENCERTIFICATE, .HC_CBORWEBTOKEN_NO_DIGITALGREENCERTIFICATE):
            return true
        case let (.HC_JSON_SCHEMA_INVALID(lhsError), .HC_JSON_SCHEMA_INVALID(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.HC_PREFIX_INVALID, .HC_PREFIX_INVALID):
            return true
        case (.AES_DECRYPTION_FAILED, .AES_DECRYPTION_FAILED):
            return true
        default:
            return false
        }
    }
}
