//
// 🦠 Corona-Warn-App
//

import Foundation
import base45_swift
import SwiftCBOR
import JSONSchema

public typealias Base45 = String
public typealias Base64 = String
public typealias CBORData = Data

let hcPrefix = "HC1:"

public protocol DigitalGreenCertificateAccessProtocol {
    func extractCBORWebTokenHeader(from base45: Base45) -> Result<CBORWebTokenHeader, CertificateDecodingError>
    func extractDigitalGreenCertificate(from base45: Base45) -> Result<DigitalGreenCertificate, CertificateDecodingError>
    func convertToBase45(from base64: Base64, with dataEncryptionKey: Data) -> Result<Base45, CertificateDecodingError>
}

public struct DigitalGreenCertificateAccess: DigitalGreenCertificateAccessProtocol {

    // MARK: - Init

    public init() {}

    // MARK: - Public

    public func extractCBORWebTokenHeader(from base45: Base45) -> Result<CBORWebTokenHeader, CertificateDecodingError> {
        let cborDataResult = extractCBOR(from: base45)

        switch cborDataResult {
        case let .success(cborData):
            return extractHeader(from: cborData)
        case let .failure(error):
            return .failure(error)
        }
    }

    public func extractDigitalGreenCertificate(from base45: Base45) -> Result<DigitalGreenCertificate, CertificateDecodingError> {
        let cborDataResult = extractCBOR(from: base45)

        switch cborDataResult {
        case let .success(cborData):
            return extractCertificate(from: cborData)
        case let .failure(error):
            return .failure(error)
        }
    }

    public func convertToBase45(from base64: Base64, with dataEncryptionKey: Data) -> Result<Base45, CertificateDecodingError> {
        let cborWebTokenResult = decryptAndComposeToWebToken(from: base64, dataEncryptionKey: dataEncryptionKey)
        if case let .failure(error) = cborWebTokenResult {
            return .failure(error)
        }
        guard case let .success(cborWebToken) = cborWebTokenResult else {
            fatalError("Has to be a success at this point, because of previous check.")
        }

        // Compress with zlib
        let cborWebTokenData = Data(cborWebToken.encode())
        let compressedCBORWebToken = cborWebTokenData.compressZLib()
        guard !compressedCBORWebToken.isEmpty else {
            return .failure(.HC_ZLIB_COMPRESSION_FAILED)
        }

        // Encode with base45
        let base45CBORWebToken = compressedCBORWebToken.toBase45()
        guard !base45CBORWebToken.isEmpty else {
            return .failure(.HC_BASE45_ENCODING_FAILED)
        }

        // Add prefix
        let prefixedBase45CBORWebToken = hcPrefix + base45CBORWebToken

        return .success(prefixedBase45CBORWebToken)
    }

    // MARK: - Internal

    func decryptAndComposeToWebToken(from base64: Base64, dataEncryptionKey: Data) -> Result<CBOR, CertificateDecodingError> {
        guard let cborData = Data(base64Encoded: base64) else {
            return .failure(.HC_BASE45_DECODING_FAILED(nil))
        }

        // Disassemble COSE object

        let result = decodeCBORWebTokenEntries(from: cborData)
        if case let .failure(error) = result {
            return .failure(error)
        }
        guard case let .success(cborWebTokenEntries) = result else {
            fatalError("Has to be a success at this point, because of previous check.")
        }

        let protectedHeader = cborWebTokenEntries[0]
        let unprotectedHeader = cborWebTokenEntries[1]
        let payload = cborWebTokenEntries[2]
        let signature = cborWebTokenEntries[3]

        guard case let .byteString(payloadBytes) = payload else {
            return .failure(.HC_COSE_MESSAGE_INVALID)
        }

        // Decrypt payload

        let aesEncryption = AESEncryption(
            encryptionKey: dataEncryptionKey,
            initializationVector: AESEncryptionConstants.initializationVector
        )

        let decryptedResult = aesEncryption.decrypt(data: Data(payloadBytes))

        guard case let .success(decryptedPayload) = decryptedResult else {
            return .failure(.AES_DECRYPTION_FAILED)
        }

        // Reassemble COSE object

        let cborWebTokenMessage = CBOR.array([
            protectedHeader,
            unprotectedHeader,
            CBOR.byteString([UInt8](decryptedPayload)),
            signature
        ])

        let cborWebToken = CBOR.tagged(CBOR.Tag(rawValue: 18), cborWebTokenMessage)
        
        return .success(cborWebToken)
    }

    func extractCBOR(from base45: Base45) -> Result<CBORData, CertificateDecodingError> {
        guard base45.hasPrefix(hcPrefix) else {
            return .failure(.HC_PREFIX_INVALID)
        }
        let base45WithoutPrefix = base45.dropPrefix(hcPrefix)

        let _zipData: Data?
        do {
            _zipData = try base45WithoutPrefix.fromBase45()
        } catch {
            return .failure(.HC_BASE45_DECODING_FAILED(error))
        }

        guard let zipData = _zipData else {
            fatalError("zipData should not be nil at this point.")
        }

        let _cborData: Data?
        do {
            _cborData = try zipData.decompressZLib()
        } catch {
            return .failure(.HC_ZLIB_DECOMPRESSION_FAILED(error))
        }

        guard let cborData = _cborData else {
            fatalError("cborData should not be nil at this point.")
        }

        return .success(cborData)
    }

    func extractHeader(from cborData: CBORData) -> Result<CBORWebTokenHeader, CertificateDecodingError> {
        let webTokenResult = decodeCBORWebTokenPayload(from: cborData)

        switch webTokenResult {
        case let .success(cborWebToken):
            return extractHeader(from: cborWebToken)
        case let .failure(error):
            return .failure(error)
        }
    }

    func extractHeader(from cborWebToken: CBOR) -> Result<CBORWebTokenHeader, CertificateDecodingError> {

        // 1: Issuer (2-letter country code)
        guard let issuerElement = cborWebToken[1],
              case let .utf8String(issuer) = issuerElement else {
            return .failure(.HC_CBORWEBTOKEN_NO_ISSUER)
        }

        // 4: Expiration time (UNIX timestamp in seconds)
        guard let expirationTimeElement = cborWebToken[4],
              case let .unsignedInt(expirationTime) = expirationTimeElement else {
            return .failure(.HC_CBORWEBTOKEN_NO_EXPIRATIONTIME)
        }

        var issuedAt: UInt64?
        // 6: Issued at (UNIX timestamp in seconds)
        if let issuedAtElement = cborWebToken[6],
           case let .unsignedInt(_issuedAt) = issuedAtElement {
            issuedAt = _issuedAt
        }

        return .success(CBORWebTokenHeader(
            issuer: issuer,
            issuedAt: issuedAt,
            expirationTime: expirationTime
        ))
    }

    func extractCertificate(from cborData: CBORData) -> Result<DigitalGreenCertificate, CertificateDecodingError> {
        let webTokenResult = decodeCBORWebTokenPayload(from: cborData)

        switch webTokenResult {
        case let .success(cborWebToken):
            return extractDigitalGreenCertificate(from: cborWebToken)
        case let .failure(error):
            return .failure(error)
        }
    }

    func extractDigitalGreenCertificate(from cborWebToken: CBOR) -> Result<DigitalGreenCertificate, CertificateDecodingError> {

        // -260: Container of Digital Green Certificate
        guard let healthCertificateElement = cborWebToken[-260],
              case let .map(healthCertificateMap) = healthCertificateElement else {
            return .failure(.HC_CBORWEBTOKEN_NO_HEALTHCERTIFICATE)
        }

        // 1: Digital Green Certificate
        guard  let healthCertificateCBOR = healthCertificateMap[1] else {
            return .failure(.HC_CBORWEBTOKEN_NO_DIGITALGREENCERTIFICATE)
        }

        switch validateSchema(of: healthCertificateCBOR) {
        case .success:
            guard case let CBOR.map(certificateMap) = healthCertificateCBOR else {
                fatalError("healthCertificateCBOR should be a map at this point.")
            }

            let dictionary = certificateMap.anyMap

            let _healthCertificate: DigitalGreenCertificate?
            do {
                _healthCertificate = try JSONDecoder().decode(DigitalGreenCertificate.self, from: JSONSerialization.data(withJSONObject: dictionary))
            } catch {
                return .failure(.HC_CBOR_DECODING_FAILED(error))
            }

            guard let healthCertificate = _healthCertificate else {
                fatalError("healthCertificate should not be nil at this point.")
            }

            return .success(healthCertificate)

        case let .failure(error):
            return .failure(error)
        }
    }

    // MARK: - Private

    private func validateSchema(of certificate: CBOR) -> Result<Void, CertificateDecodingError> {

        guard case let CBOR.map(certificateMap) = certificate,
            let schemaURL = Bundle.module.url(forResource: "CertificateSchema", withExtension: "json"),
              let schemaData = FileManager.default.contents(atPath: schemaURL.path) else {

            return .failure(.HC_JSON_SCHEMA_INVALID(.FILE_NOT_FOUND))
        }

        guard let schemaDict = try? JSONSerialization.jsonObject(with: schemaData) as? [String: Any] else {
            return .failure(.HC_JSON_SCHEMA_INVALID(.DECODING_FAILED))

        }

        let _validationResult: ValidationResult?
        do {
            _validationResult = try JSONSchema.validate(certificateMap.anyMap, schema: schemaDict)
        } catch {
            return .failure(.HC_JSON_SCHEMA_INVALID(.VALIDATION_FAILED(error)))
        }

        guard let validationResult = _validationResult else {
            fatalError("validationResult should not be nil at this point.")
        }

        switch validationResult {
        case .invalid(let errors):
            return .failure(.HC_JSON_SCHEMA_INVALID(.VALIDATION_RESULT_FAILED(errors)))
        case .valid:
            return .success(())
        }
    }

    /// More information about the CBOR Web Token (CWT) https://datatracker.ietf.org/doc/html/rfc8392
    private func decodeCBORWebTokenPayload(from cborData: CBORData) -> Result<CBOR, CertificateDecodingError> {
        let result = decodeCBORWebTokenEntries(from: cborData)

        if case let .failure(error) = result {
            return .failure(error)
        }
        guard case let .success(cborWebTokenEntries) = result else {
            fatalError("Has to be a success at this point, because of previous check.")
        }

        guard case let CBOR.byteString(payloadBytes) = cborWebTokenEntries[2] else {
            return .failure(.HC_COSE_MESSAGE_INVALID)
        }

        let payloadDecoder = CBORDecoder(input: payloadBytes)

        let _payload: CBOR?
        do {
            _payload = try payloadDecoder.decodeItem()
        } catch {
            return .failure(.HC_CBOR_DECODING_FAILED(error))
        }

        guard let payload = _payload else {
            fatalError("payload should not be nil at this point.")
        }

        return .success(payload)
    }

    private func decodeCBORWebTokenEntries(from cborData: CBORData) -> Result<[CBOR], CertificateDecodingError> {
        let cborDecoder = CBORDecoder(input: [UInt8](cborData))

        let _cborPayload: CBOR?
        do {
            _cborPayload = try cborDecoder.decodeItem()
        } catch {
            return .failure(.HC_CBOR_DECODING_FAILED(error))
        }
        guard let cborPayload = _cborPayload else {
            fatalError("cborPayload should not be nil at this point.")
        }

        guard case let CBOR.tagged(tag, cborWebTokenMessage) = cborPayload,
              // 18: CBOR tag value for a COSE Single Signer Data Object
              tag.rawValue == 18 else {

            return .failure(.HC_COSE_TAG_INVALID)
        }

        guard
            case let CBOR.array(cborWebTokenEntries) = cborWebTokenMessage,
            // The message has to have 4 entries.
            cborWebTokenEntries.count == 4 else {

            return .failure(.HC_COSE_MESSAGE_INVALID)
        }

        return .success(cborWebTokenEntries)
    }
}
