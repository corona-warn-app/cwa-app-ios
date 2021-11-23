//
// 🦠 Corona-Warn-App
//

import Foundation
import base45_swift
import SwiftCBOR
import JSONSchema
import ENASecurity

public typealias Base45 = String
public typealias Base64 = String
public typealias CBORData = Data

let hcPrefix = "HC1:"

public protocol DigitalCovidCertificateAccessProtocol {
    func extractCBORWebTokenHeader(from base45: Base45) -> Result<CBORWebTokenHeader, CertificateDecodingError>
    func extractDigitalCovidCertificate(from base45: Base45) -> Result<DigitalCovidCertificate, CertificateDecodingError>
    func convertToBase45(from base64: Base64, with dataEncryptionKey: Data) -> Result<Base45, CertificateDecodingError>
}

public struct DigitalCovidCertificateAccess: DigitalCovidCertificateAccessProtocol {

    // MARK: - Init

    public init() {}

    // MARK: - Public

    public func extractCBORWebTokenHeader(from base45: Base45) -> Result<CBORWebTokenHeader, CertificateDecodingError> {
        removePrefix(from: base45)
            .flatMap(convertBase45ToData)
            .flatMap(decompressZLib)
            .flatMap(decodeCOSEEntries)
            .flatMap(extractCOSEPayload)
            .flatMap(decodeDataToCBOR)
            .flatMap(extractWebTokenHeader)
    }

    public func extractDigitalCovidCertificate(from base45: Base45) -> Result<DigitalCovidCertificate, CertificateDecodingError> {
        removePrefix(from: base45)
            .flatMap(convertBase45ToData)
            .flatMap(decompressZLib)
            .flatMap(decodeCOSEEntries)
            .flatMap(extractCOSEPayload)
            .flatMap(decodeDataToCBOR)
            .flatMap(extractDigitalCovidCertificate)
    }

    public func extractKeyIdentifier(from base45: Base45) -> Result<Base64, CertificateDecodingError> {
        removePrefix(from: base45)
            .flatMap(convertBase45ToData)
            .flatMap(decompressZLib)
            .flatMap(decodeCOSEEntries)
            .flatMap(extractKeyIdentifier)
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

    func extractCOSEEntries(from base45: Base45) -> Result<[CBOR], CertificateDecodingError> {
        removePrefix(from: base45)
            .flatMap(convertBase45ToData)
            .flatMap(decompressZLib)
            .flatMap(decodeCOSEEntries)
    }

    func decryptAndComposeToWebToken(from base64: Base64, dataEncryptionKey: Data) -> Result<CBOR, CertificateDecodingError> {
        let entriesResult = convertBase64ToData(base64: base64)
            .flatMap(decodeCOSEEntries)

        guard case let .success(webTokenEntries) = entriesResult else {
            return .failure(.AES_DECRYPTION_FAILED)
        }

        return convertBase64ToData(base64: base64)
            .flatMap(decodeCOSEEntries)
            .flatMap(extractCOSEPayload)
            .flatMap { decryptPayload(payload: $0, dataEncryptionKey: dataEncryptionKey) }
            .map { reassembleCose(webTokenEntries: webTokenEntries, payload: $0) }
    }

    func extractKeyIdentifier(from coseEntries: [CBOR]) -> Result<Base64, CertificateDecodingError> {
        if case let .byteString(protectedHeaderBytes) = coseEntries[0],
           let protectedHeaderCBOR = try? CBORDecoder(input: protectedHeaderBytes).decodeItem(),
           case let .byteString(keyIdentifierBytes) = protectedHeaderCBOR[4] {
            return .success(Data(keyIdentifierBytes).base64EncodedString())
        }

        let unprotectedHeaderCBOR = coseEntries[1]
        if case let .byteString(keyIdentifierBytes) = unprotectedHeaderCBOR[4] {
            return .success(Data(keyIdentifierBytes).base64EncodedString())
        }

        return .failure(.HC_COSE_NO_KEYIDENTIFIER)
    }

    func extractCOSEPayload(from coseEntries: [CBOR]) -> Result<Data, CertificateDecodingError> {
        let payload = coseEntries[2]
        if case let .byteString(payloadBytes) = payload {
            return .success(Data(payloadBytes))
        } else {
            return .failure(.HC_COSE_MESSAGE_INVALID)
        }
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

    private func decryptPayload(payload: Data, dataEncryptionKey: Data) -> Result<Data, CertificateDecodingError> {
        let cbcEncryption = CBCEncryption(
            encryptionKey: dataEncryptionKey,
            initializationVector: AESEncryptionConstants.zeroInitializationVector
        )

        let decryptedResult = cbcEncryption.decrypt(data: payload)
        if case let .success(decryptedPayload) = decryptedResult {
            return .success(decryptedPayload)
        } else {
            return .failure(.AES_DECRYPTION_FAILED)
        }
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

    private func extractWebTokenHeader(from cosePayload: CBOR) -> Result<CBORWebTokenHeader, CertificateDecodingError> {

        // 1: Issuer (2-letter country code)
        guard let issuerElement = cosePayload[1],
              case let .utf8String(issuer) = issuerElement else {
            return .failure(.HC_CBORWEBTOKEN_NO_ISSUER)
        }

        // 4: Expiration time (UNIX timestamp in seconds)
        guard let expirationTimeElement = cosePayload[4],
              let expirationTime = date(from: expirationTimeElement) else {
            return .failure(.HC_CBORWEBTOKEN_NO_EXPIRATIONTIME)
        }

        // 6: Issued at (UNIX timestamp in seconds)
        // 'iat' (issuedAt) should not be nil, so we assign it a default 0 here to avoid optionality.
        // We are not returning an error here, because of backwards compatibility, due to a change from optional to non-optional.
        let issuedAt = cosePayload[6].flatMap { date(from: $0) } ?? Date(timeIntervalSince1970: 0)

        return .success(CBORWebTokenHeader(
            issuer: issuer,
            issuedAt: issuedAt,
            expirationTime: expirationTime
        ))
    }

    private func date(from element: CBOR) -> Date? {
        var date: Date?
        switch element {
        case let .unsignedInt(_date):
            date = Date(timeIntervalSince1970: TimeInterval(_date))
        case let .negativeInt(_date):
            date = Date(timeIntervalSince1970: TimeInterval(_date))
        case let .float(_date):
            date = Date(timeIntervalSince1970: TimeInterval(_date))
        case let .double(_date):
            date = Date(timeIntervalSince1970: TimeInterval(_date))
        case let .date(_date):
            date = _date
        case .byteString, .utf8String, .array, .map, .tagged, .simple, .boolean, .null, .undefined, .half, .break:
            return nil
        }

        return date
    }

    private func extractDigitalCovidCertificate(from cborWebToken: CBOR) -> Result<DigitalCovidCertificate, CertificateDecodingError> {

        // -260: Container of Digital Covid Certificate
        guard let healthCertificateElement = cborWebToken[-260],
              case let .map(healthCertificateMap) = healthCertificateElement else {
            return .failure(.HC_CBORWEBTOKEN_NO_HEALTHCERTIFICATE)
        }

        // 1: Digital Covid Certificate
        guard  let healthCertificateCBOR = healthCertificateMap[1] else {
            return .failure(.HC_CBORWEBTOKEN_NO_DIGITALGREENCERTIFICATE)
        }
        
        guard let trimmedHealthCertificateCBOR = cborMapWithTrimming(certificateCBOR: healthCertificateCBOR) else {
            return .failure(.HC_CBOR_TRIMMING_FAILED)
        }
        return loadSchemaAsDict()
            .flatMap { validateSchema(of: trimmedHealthCertificateCBOR, schemaDict: $0) }
            .flatMap(convertCBORToStruct)
    }
    
    private func cborMapWithTrimming(certificateCBOR: CBOR) -> CBOR? {
        guard case let CBOR.map(certificateMap) = certificateCBOR else {
            return nil
        }
        // we need to remove spaces from attributes of the certificate CBOR itself so we pass back a modifiedCertificate
        return CBOR.map(certificateMap.trimmed)
    }


    private func convertCBORToStruct(_ cbor: CBOR) -> Result<DigitalCovidCertificate, CertificateDecodingError> {
        guard case let CBOR.map(certificateMap) = cbor else {
            fatalError("healthCertificateCBOR should be a map at this point.")
        }

        do {
            let healthCertificate = try JSONDecoder().decode(DigitalCovidCertificate.self, from: JSONSerialization.data(withJSONObject: certificateMap.anyMap))
            return .success(healthCertificate)
        } catch {
            return .failure(.HC_CBOR_DECODING_FAILED(error))
        }
    }

    private func loadSchemaAsDict() -> Result<[String: Any], CertificateDecodingError> {
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
                return .success(certificate)
            }
        } catch {
            return .failure(.HC_JSON_SCHEMA_INVALID(.VALIDATION_FAILED(error)))
        }
    }
    
    private func decodeCOSEEntries(from cborData: CBORData) -> Result<[CBOR], CertificateDecodingError> {
        decodeDataToCBOR(cborData)
            .flatMap(extractCOSE)
            .flatMap(extractCOSEEntries)
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
        // COSE is one of the following ...

        // ... a tagged CBOR message with tag 18, which indicates signed data. The value is an array with exactly 4 elements.
        if case let CBOR.tagged(tag, cborWebTokenMessage) = cborPayload,
              // 18: CBOR tag value for a COSE Single Signer Data Object
              tag.rawValue == 18 {
            return .success(cborWebTokenMessage)
        }
        // ... an array with exactly four elements (i.e. no tagged CBOR message).
        else if case let CBOR.array(coseArray) = cborPayload,
                coseArray.count == 4 {
            // Return cborPayload directly because it is already what we need in further steps. A CBOR array with 4 entries.
            return .success(cborPayload)
        } else {
            return .failure(.HC_COSE_TAG_OR_ARRAY_INVALID)
        }
    }

    private func extractCOSEEntries(_ cose: CBOR) -> Result<[CBOR], CertificateDecodingError> {
        guard
            case let CBOR.array(cborWebTokenEntries) = cose,
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

    private func encodeWithBase45(data: Data) -> Result<String, CertificateDecodingError> {
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
