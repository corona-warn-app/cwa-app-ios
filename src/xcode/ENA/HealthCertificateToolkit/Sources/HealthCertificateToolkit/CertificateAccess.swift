//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftCBOR

struct CertificateAccess {

    // MARK: - Internal

    func extractHeader(from cborData: Data) -> Result<CBORWebTokenHeader, CertificateDecodingError> {
        let webTokenResult = decodeCBORWebToken(cborData)

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

    func extractDigitalGreenCertificate(from cborData: Data) -> Result<DigitalGreenCertificate, CertificateDecodingError> {
        let webTokenResult = decodeCBORWebToken(cborData)

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

        let _cborData = healthCertificateCBOR.encode()
        let cborData = Data(_cborData)

        let codableDecoder = CodableCBORDecoder()

        guard let healthCertificate = try? codableDecoder.decode(DigitalGreenCertificate.self, from: cborData) else {
            return .failure(.HC_CBOR_DECODING_FAILED)
        }

        return .success(healthCertificate)
    }

    // MARK: - Private

    private func decodeCBORWebToken(_ cborData: Data) -> Result<CBOR, CertificateDecodingError>  {
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
