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
        extractCBOR(from: base45)
            .flatMap(decodeCBORWebTokenPayload)
            .flatMap(extractHeader)
    }

    public func extractDigitalGreenCertificate(from base45: Base45) -> Result<DigitalGreenCertificate, CertificateDecodingError> {
        extractCBOR(from: base45)
            .flatMap(decodeCBORWebTokenPayload)
            .flatMap(extractDigitalGreenCertificate)
    }

    public func convertToBase45(from base64: Base64, with dataEncryptionKey: Data) -> Result<Base45, CertificateDecodingError> {
        decryptAndComposeToWebToken(from: base64, dataEncryptionKey: dataEncryptionKey)
            .flatMap(compressWithZLib)
            .flatMap(encodeWithBase45)
            .map {
                // Add prefix
                hcPrefix + $0
            }
    }

    // MARK: - Internal

    func decryptAndComposeToWebToken(from base64: Base64, dataEncryptionKey: Data) -> Result<CBOR, CertificateDecodingError> {
        let entriesResult = convertBase64ToData(base64: base64)
            .flatMap(decodeCBORWebTokenEntries)

        guard case let .success(webTokenEntries) = entriesResult else {
            return .failure(.AES_DECRYPTION_FAILED)
        }

        return convertBase64ToData(base64: base64)
            .flatMap(decodeCBORWebTokenEntries)
            .flatMap(extractPayload)
            .flatMap { decryptPayload(payload: $0, dataEncryptionKey: dataEncryptionKey) }
            .map{ reassembleCose(webTokenEntries: webTokenEntries, payload: $0) }
    }

    // MARK: - Private

    private func reassembleCose(webTokenEntries: [CBOR], payload: Data) -> CBOR {
        let protectedHeader = webTokenEntries[0]
        let unprotectedHeader = webTokenEntries[1]
        let signature = webTokenEntries[3]

        let cborWebTokenMessage = CBOR.array([
            protectedHeader,
            unprotectedHeader,
            CBOR.byteString([UInt8](payload)),
            signature
        ])

        return CBOR.tagged(CBOR.Tag(rawValue: 18), cborWebTokenMessage)
    }

    private func extractPayload(from cborWebTokenEntries: [CBOR]) -> Result<Data, CertificateDecodingError> {
        let payload = cborWebTokenEntries[2]
        if case let .byteString(payloadBytes) = payload {
            return .success(Data(payloadBytes))
        } else {
            return .failure(.HC_COSE_MESSAGE_INVALID)
        }
    }

    private func decryptPayload(payload: Data, dataEncryptionKey: Data) -> Result<Data, CertificateDecodingError> {
        let aesEncryption = AESEncryption(
            encryptionKey: dataEncryptionKey,
            initializationVector: AESEncryptionConstants.initializationVector
        )

        let decryptedResult = aesEncryption.decrypt(data: payload)
        if case let .success(decryptedPayload) = decryptedResult {
            return .success(decryptedPayload)
        } else {
            return .failure(.AES_DECRYPTION_FAILED)
        }
    }

    private func extractCBOR(from base45: Base45) -> Result<CBORData, CertificateDecodingError> {
        removePrefix(from: base45)
            .flatMap(convertBase45ToData)
            .flatMap(decompressZLib)
    }

    private func decompressZLib(form data: Data) -> Result<Data, CertificateDecodingError> {
        do {
            let data = try data.decompressZLib()
            return .success(data)
        } catch {
            return .failure(.HC_ZLIB_DECOMPRESSION_FAILED(error))
        }
    }

    private func convertBase45ToData(base45: Base45) -> Result<Data, CertificateDecodingError> {
        do {
            let data = try base45.fromBase45()
            return .success(data)
        } catch {
            return .failure(.HC_BASE45_DECODING_FAILED(error))
        }
    }

    private func removePrefix(from base45: Base45) -> Result<Base45, CertificateDecodingError> {
        guard base45.hasPrefix(hcPrefix) else {
            return .failure(.HC_PREFIX_INVALID)
        }
        return .success(base45.dropPrefix(hcPrefix))
    }

    private func extractHeader(from cborWebToken: CBOR) -> Result<CBORWebTokenHeader, CertificateDecodingError> {

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

    private func extractDigitalGreenCertificate(from cborWebToken: CBOR) -> Result<DigitalGreenCertificate, CertificateDecodingError> {

        // -260: Container of Digital Green Certificate
        guard let healthCertificateElement = cborWebToken[-260],
              case let .map(healthCertificateMap) = healthCertificateElement else {
            return .failure(.HC_CBORWEBTOKEN_NO_HEALTHCERTIFICATE)
        }

        // 1: Digital Green Certificate
        guard  let healthCertificateCBOR = healthCertificateMap[1] else {
            return .failure(.HC_CBORWEBTOKEN_NO_DIGITALGREENCERTIFICATE)
        }

        return loadSchemaAsDict()
            .flatMap { validateSchema(of: healthCertificateCBOR, schemaDict: $0) }
            .flatMap(convertCBORToStruct)
    }

    private func convertCBORToStruct(_ cbor: CBOR) -> Result<DigitalGreenCertificate, CertificateDecodingError>  {
        guard case let CBOR.map(certificateMap) = cbor else {
            fatalError("healthCertificateCBOR should be a map at this point.")
        }

        do {
            let healthCertificate = try JSONDecoder().decode(DigitalGreenCertificate.self, from: JSONSerialization.data(withJSONObject: certificateMap.anyMap))
            return .success(healthCertificate)
        } catch {
            return .failure(.HC_CBOR_DECODING_FAILED(error))
        }
    }

    private func loadSchemaAsDict() -> Result<[String: Any], CertificateDecodingError>  {
        guard let schemaURL = Bundle.module.url(forResource: "CertificateSchema", withExtension: "json"),
              let schemaData = FileManager.default.contents(atPath: schemaURL.path) else {
            return .failure(.HC_JSON_SCHEMA_INVALID(.FILE_NOT_FOUND))
        }
        guard let schemaDict = try? JSONSerialization.jsonObject(with: schemaData) as? [String: Any] else {
            return .failure(.HC_JSON_SCHEMA_INVALID(.DECODING_FAILED))
        }
        return .success(schemaDict)
    }

    private func validateSchema(of certificate: CBOR, schemaDict: [String: Any]) -> Result<CBOR, CertificateDecodingError> {
        do {
            guard case let CBOR.map(certificateMap) = certificate else {
                return .failure(.HC_JSON_SCHEMA_INVALID(.DECODING_FAILED))
            }

            let validationResult = try JSONSchema.validate(certificateMap.anyMap, schema: schemaDict)

            switch validationResult {
            case .invalid(let errors):
                return .failure(.HC_JSON_SCHEMA_INVALID(.VALIDATION_RESULT_FAILED(errors)))
            case .valid:
                return .success((certificate))
            }
        } catch {
            return .failure(.HC_JSON_SCHEMA_INVALID(.VALIDATION_FAILED(error)))
        }
    }

    /// More information about the CBOR Web Token (CWT) https://datatracker.ietf.org/doc/html/rfc8392
    private func decodeCBORWebTokenPayload(from cborData: CBORData) -> Result<CBOR, CertificateDecodingError> {
        decodeCBORWebTokenEntries(from: cborData)
            .flatMap(extractPayload)
            .flatMap(decodePayload)
    }

    private func decodePayload(from data: Data) -> Result<CBOR, CertificateDecodingError> {
        let payloadDecoder = CBORDecoder(input: [UInt8](data))
        do {
            guard let payload = try payloadDecoder.decodeItem() else {
                return .failure(.HC_CBOR_DECODING_FAILED(nil))
            }
            return .success(payload)
        } catch {
            return .failure(.HC_CBOR_DECODING_FAILED(error))
        }
    }

    private func decodeCBORWebTokenEntries(from cborData: CBORData) -> Result<[CBOR], CertificateDecodingError> {
        decodeDataToCBOR(cborData)
            .flatMap(extractCOSE)
            .flatMap(extractWebTokenEntries)
    }

    private func decodeDataToCBOR(_ cborData: CBORData) -> Result<CBOR, CertificateDecodingError> {
        do {
            let cborDecoder = CBORDecoder(input: [UInt8](cborData))
            guard let cbor = try cborDecoder.decodeItem() else {
                return .failure(.HC_CBOR_DECODING_FAILED(nil))
            }
            return .success(cbor)
        } catch {
            return .failure(.HC_CBOR_DECODING_FAILED(error))
        }
    }

    private func extractCOSE(from cborPayload: CBOR) -> Result<CBOR, CertificateDecodingError> {
        guard case let CBOR.tagged(tag, cborWebTokenMessage) = cborPayload,
              // 18: CBOR tag value for a COSE Single Signer Data Object
              tag.rawValue == 18 else {

            return .failure(.HC_COSE_TAG_INVALID)
        }

        return .success(cborWebTokenMessage)
    }

    private func extractWebTokenEntries(_ cborWebToken: CBOR) -> Result<[CBOR], CertificateDecodingError> {
        guard
            case let CBOR.array(cborWebTokenEntries) = cborWebToken,
            // The message has to have 4 entries.
            cborWebTokenEntries.count == 4 else {

            return .failure(.HC_COSE_MESSAGE_INVALID)
        }
        return .success(cborWebTokenEntries)
    }

    private func compressWithZLib(cborWebToken: CBOR) -> Result<Data, CertificateDecodingError> {
        let cborWebTokenData = Data(cborWebToken.encode())
        let compressedCBORWebToken = cborWebTokenData.compressZLib()
        guard !compressedCBORWebToken.isEmpty else {
            return .failure(.HC_ZLIB_COMPRESSION_FAILED)
        }
        return .success(compressedCBORWebToken)
    }

    private func encodeWithBase45(data: Data) -> Result<String, CertificateDecodingError>  {
        let encodedData = data.toBase45()
        guard !encodedData.isEmpty else {
            return .failure(.HC_BASE45_ENCODING_FAILED)
        }
        return .success(encodedData)
    }

    private func convertBase64ToData(base64: Base64) -> Result<Data, CertificateDecodingError> {
        if let cborData = Data(base64Encoded: base64) {
            return .success(cborData)
        } else {
            return .failure(.HC_BASE45_DECODING_FAILED(nil))
        }
    }
}
