//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftCBOR
import JSONSchema

struct CertificateAccess {

    // MARK: - Internal

    func extractHeader(from cborData: Data) -> Result<CBORWebTokenHeader, HealthCertificateDecodingError> {
        let webTokenResult = decodeCBORWebToken(cborData)

        switch webTokenResult {
        case let .success(cborWebToken):

            let headerResult = extractHeader(from: cborWebToken)

            switch headerResult {
            case let .success(tokenHeader):
                return .success(tokenHeader)
            case let .failure(error):
                return .failure(error)
            }

        case let .failure(error):
            return .failure(error)
        }
    }

    func extractHeader(from cborWebToken: CBOR) -> Result<CBORWebTokenHeader, HealthCertificateDecodingError> {
        guard let issuerElement = cborWebToken[1],
              case let .utf8String(issuer) = issuerElement else {
            return .failure(.HC_CWT_NO_ISS)
        }

        guard let expirationTimeElement = cborWebToken[6],
              case let .unsignedInt(expirationTime) = expirationTimeElement else {
            return .failure(.HC_CWT_NO_EXP)
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

    func extractHealthCertificate(from cborData: Data) -> Result<DigitalGreenCertificate, HealthCertificateDecodingError> {
        let webTokenResult = decodeCBORWebToken(cborData)

        switch webTokenResult {
        case let .success(cborWebToken):

            let certificateResult = extractHealthCertificate(from: cborWebToken)

            switch certificateResult {
            case let .success(certificate):
                return .success(certificate)
            case let .failure(error):
                return .failure(error)
            }

        case let .failure(error):
            return .failure(error)
        }
    }

    func extractHealthCertificate(from cborWebToken: CBOR) -> Result<DigitalGreenCertificate, HealthCertificateDecodingError> {
        guard let healthCertificateElement = cborWebToken[-260],
              case let .map(healthCertificateMap) = healthCertificateElement else {
            return .failure(.HC_CWT_NO_HCERT)
        }

        guard  let healthCertificateCBOR = healthCertificateMap[1] else {
            return .failure(.HC_CWT_NO_DGC)
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

    private func validateSchema(of certificate: CBOR) -> Result<Void, HealthCertificateDecodingError> {
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

    private func decodeCBORWebToken(_ cborData: Data) -> Result<CBOR, HealthCertificateDecodingError>  {
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
