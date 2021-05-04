//
// 🦠 Corona-Warn-App
//


import Foundation
import SwiftCBOR
import base45_swift

public typealias DecodeHealthCertificateResult = Result<HealthCertificateRepresentations, HealthCertificateDecodingError>
public typealias FetchProofCertificateResult = Result<ProofCertificateRepresentations, ProofCertificateFetchingError>

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
}

public protocol HealthCertificateToolkitProtocol {

    func decodeHealthCertificate(base45: String) -> DecodeHealthCertificateResult

    func fetchProofCertificate(for healthCertificates: [HealthCertificateRepresentations], completion: (FetchProofCertificateResult) -> Void)
}

public struct HealthCertificateToolkit: HealthCertificateToolkitProtocol {

    // MARK: - Protocol HealthCertificateToolkitProtocol

    public func decodeHealthCertificate(base45: String) -> DecodeHealthCertificateResult {
        guard let zipData = try? base45.fromBase45() else {
            return .failure(.HC_BASE45_DECODING_FAILED)
        }

        guard let cborData =  try? zipData.decompressZLib() else {
            return .failure(.HC_ZLIB_DECOMPRESSION_FAILED)
        }
        let cosePayloadResult = decodeCOSEPayload(cborData)

        guard case let .success(cosePayload) = cosePayloadResult else {
            if case let .failure(error) = cosePayloadResult {
                return .failure(error)
            } else {
                fatalError("Has to be an error at this point.")
            }
        }

        let cborWebTokenResult = decodeCBORWebToken(cosePayload)
        guard case let .success(cborWebToken) = cborWebTokenResult else {
            if case let .failure(error) = cosePayloadResult {
                return .failure(error)
            } else {
                fatalError("Has to be an error at this point.")
            }
        }

        let headerResult = extractHeader(cborWebToken)
        guard case let .success(header) = headerResult else {
            if case let .failure(error) = headerResult {
                return .failure(error)
            } else {
                fatalError("Has to be an error at this point.")
            }
        }

        let certificateResult = extractHealthCertificate(cborWebToken)
        guard case let .success(certificate) = certificateResult else {
            if case let .failure(error) = certificateResult {
                return .failure(error)
            } else {
                fatalError("Has to be an error at this point.")
            }
        }

        let certificateRepresentation = HealthCertificateRepresentations(
            base45: base45,
            cbor: cborData,
            header: header,
            certificate: certificate
        )

        return .success(certificateRepresentation)
    }

    public func fetchProofCertificate(for healthCertificates: [HealthCertificateRepresentations], completion: (FetchProofCertificateResult) -> Void) {

    }

    // MARK: - Internal

    func decodeCOSEPayload(_ data: Data) -> Result<Data, HealthCertificateDecodingError> {
        let decoder = CBORDecoder(input: [UInt8](data))

        guard
            let cbor = try? decoder.decodeItem(),
            case let CBOR.tagged(tag, messageElement) = cbor,
            tag.rawValue == 18 else {

            return .failure(.HC_COSE_TAG_INVALID)
        }

        guard
            case let CBOR.array(message) = messageElement,
            message.count == 4,
            case let CBOR.byteString(payload) = message[2] else {

            return .failure(.HC_COSE_MESSAGE_INVALID)
        }

        return .success(Data(payload))
    }

    func decodeCBORWebToken(_ data: Data) -> Result<CBOR, HealthCertificateDecodingError>  {
        let decoder = CBORDecoder(input: [UInt8](data))

        guard let payload = try? decoder.decodeItem() else {
            return .failure(.HC_CBOR_DECODING_FAILED)
        }

        return .success(payload)
    }

    func extractHeader(_ cbor: CBOR) -> Result<HealthCertificateHeader, HealthCertificateDecodingError> {

        guard let issuerElement = cbor[1],
              case let .utf8String(issuer) = issuerElement else {
            return .failure(.HC_CWT_NO_ISS)
        }

        guard let expirationTimeElement = cbor[6],
              case let .unsignedInt(expirationTime) = expirationTimeElement else {
            return .failure(.HC_CWT_NO_EXP)
        }

        var issuedAt: UInt64?
        if let issuedAtElement = cbor[4],
           case let .unsignedInt(_issuedAt) = issuedAtElement {
            issuedAt = _issuedAt
        }

        return .success(HealthCertificateHeader(
            issuer: issuer,
            issuedAt: issuedAt,
            expirationTime: expirationTime
        ))
    }

    func extractHealthCertificate(_ cbor: CBOR) -> Result<HealthCertificate, HealthCertificateDecodingError> {

        guard let healthCertificateElement = cbor[-260],
              case let .map(healthCertificateMap) = healthCertificateElement else {
            return .failure(.HC_CWT_NO_HCERT)
        }

        guard  let healthCertificateCBOR = healthCertificateMap[1] else {
            return .failure(.HC_CWT_NO_DGC)
        }

        let _cborData = healthCertificateCBOR.encode()
        let cborData = Data(_cborData)

        let codableDecoder = CodableCBORDecoder()

        guard let healthCertificate = try? codableDecoder.decode(HealthCertificate.self, from: cborData) else {
            return .failure(.HC_CBOR_DECODING_FAILED)
        }

        return .success(healthCertificate)
    }
}

// MARK: - Fakes

public struct HealthCertificateToolkitStub: HealthCertificateToolkitProtocol {

    // MARK: - Init

    init(
        decodeResult: DecodeHealthCertificateResult,
        fetchProofCertificateResult: FetchProofCertificateResult
    ) {
        self.decodeResult = decodeResult
        self.fetchProofCertificateResult = fetchProofCertificateResult
    }

    // MARK: - Public

    public func decodeHealthCertificate(base45: String) -> DecodeHealthCertificateResult {
        decodeResult
    }

    public func fetchProofCertificate(for healthCertificates: [HealthCertificateRepresentations], completion: (FetchProofCertificateResult) -> Void) {
        completion(fetchProofCertificateResult)
    }

    // MARK: - Private

    private let decodeResult: DecodeHealthCertificateResult
    private let fetchProofCertificateResult: FetchProofCertificateResult

}
