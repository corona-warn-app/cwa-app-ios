//
// 🦠 Corona-Warn-App
//

import Foundation
import base45_swift
import SwiftCBOR
import JSONSchema

public typealias Base45 = String
public typealias CBORData = Data

public struct DigitalGreenCertificateAccess {

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

    public func extractCBORWebTokenHeader(from cborData: CBORData) -> Result<CBORWebTokenHeader, CertificateDecodingError> {
        return extractHeader(from: cborData)
    }

    public func extractDigitalGreenCertificate(from base45: Base45) -> Result<DigitalGreenCertificate, CertificateDecodingError> {
        let cborDataResult = extractCBOR(from: base45)

        switch cborDataResult {
        case let .success(cborData):
            return extractDigitalGreenCertificate(from: cborData)
        case let .failure(error):
            return .failure(error)
        }
    }

    public func extractDigitalGreenCertificate(from cborData: CBORData) -> Result<DigitalGreenCertificate, CertificateDecodingError> {
        return extractCertificate(from: cborData)
    }

    // MARK: - Internal

    func extractCBOR(from base45: Base45) -> Result<CBORData, CertificateDecodingError> {
        guard let zipData = try? base45.fromBase45() else {
            return .failure(.HC_BASE45_DECODING_FAILED)
        }

        guard let cborData =  try? zipData.decompressZLib() else {
            return .failure(.HC_ZLIB_DECOMPRESSION_FAILED)
        }

        return .success(cborData)
    }

    func extractHeader(from cborData: CBORData) -> Result<CBORWebTokenHeader, CertificateDecodingError> {
        let webTokenResult = decodeCBORWebToken(from: cborData)

        switch webTokenResult {
        case let .success(cborWebToken):

            let headerResult = extractHeader(from: cborWebToken)

            return headerResult

        case let .failure(error):
            return .failure(error)
        }
    }

    func extractHeader(from cborWebToken: CBOR) -> Result<CBORWebTokenHeader, CertificateDecodingError> {
        guard let issuerElement = cborWebToken[1],
              case let .utf8String(issuer) = issuerElement else {
            return .failure(.HC_CBORWEBTOKEN_NO_ISSUER)
        }

        guard let expirationTimeElement = cborWebToken[6],
              case let .unsignedInt(expirationTime) = expirationTimeElement else {
            return .failure(.HC_CBORWEBTOKEN_NO_EXPIRATIONTIME)
        }

        var issuedAt: UInt64?
        if let issuedAtElement = cborWebToken[4],
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
        let webTokenResult = decodeCBORWebToken(from: cborData)

        switch webTokenResult {
        case let .success(cborWebToken):
            let certificateResult = extractDigitalGreenCertificate(from: cborWebToken)
            return certificateResult

        case let .failure(error):
            return .failure(error)
        }
    }

    func extractDigitalGreenCertificate(from cborWebToken: CBOR) -> Result<DigitalGreenCertificate, CertificateDecodingError> {
        guard let healthCertificateElement = cborWebToken[-260],
              case let .map(healthCertificateMap) = healthCertificateElement else {
            return .failure(.HC_CBORWEBTOKEN_NO_HEALTHCERTIFICATE)
        }

        guard  let healthCertificateCBOR = healthCertificateMap[1] else {
            return .failure(.HC_CBORWEBTOKEN_NO_DIGITALGREENCERTIFICATE)
        }

        switch validateSchema(of: healthCertificateCBOR) {
        case .success:
            let _cborData = healthCertificateCBOR.encode()
            let cborData = Data(_cborData)
            let codableDecoder = CodableCBORDecoder()

            guard let healthCertificate = try? codableDecoder.decode(DigitalGreenCertificate.self, from: cborData) else {
                return .failure(.HC_CBOR_DECODING_FAILED)
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
              let schemaData = FileManager.default.contents(atPath: schemaURL.path),
              let schemaDict = try? JSONSerialization.jsonObject(with: schemaData) as? [String: Any],
              let validationResult = try? JSONSchema.validate(certificateMap, schema: schemaDict),
              case .valid = validationResult else {

            return .failure(.HC_JSON_SCHEMA_INVALID)
        }

        return .success(())
    }

    private func decodeCBORWebToken(from cborData: CBORData) -> Result<CBOR, CertificateDecodingError>  {
        let cborDecoder = CBORDecoder(input: [UInt8](cborData))

        guard
            let cborPayload = try? cborDecoder.decodeItem(),
            case let CBOR.tagged(tag, messageElement) = cborPayload,
            tag.rawValue == 18 else {

            return .failure(.HC_COSE_TAG_INVALID)
        }

        guard
            case let CBOR.array(message) = messageElement,
            message.count == 4,
            case let CBOR.byteString(payloadBytes) = message[2] else {

            return .failure(.HC_COSE_MESSAGE_INVALID)
        }

        let payloadDecoder = CBORDecoder(input: [UInt8](payloadBytes))

        guard let payload = try? payloadDecoder.decodeItem() else {
            return .failure(.HC_CBOR_DECODING_FAILED)
        }

        return .success(payload)
    }
}
