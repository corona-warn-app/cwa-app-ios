//
// 🦠 Corona-Warn-App
//


import Foundation
import SwiftCBOR
import base45_swift

public typealias DecodeHealthCertificateResult = Result<CertificateRepresentations, HealthCertificateDecodingError>
public typealias FetchProofCertificateResult = Result<CertificateRepresentations, ProofCertificateFetchingError>

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
}

public protocol HealthCertificateToolkitProtocol {

    func decodeHealthCertificate(base45: String) -> DecodeHealthCertificateResult

    func fetchProofCertificate(for healthCertificates: [CertificateRepresentations], completion: (FetchProofCertificateResult) -> Void)
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

        guard let jsonData = try? extractJSON(cosePayload) else {
            return .failure(.HC_CBOR_DECODING_FAILED)
        }

        let certificateRepresentation = HealthCertificateRepresentations(
            base45: base45,
            cbor: cborData,
            json: jsonData
        )

        return .success(certificateRepresentation)
    }

    public func fetchProofCertificate(for healthCertificates: [CertificateRepresentations], completion: (FetchProofCertificateResult) -> Void) {

    }

    // MARK: - Internal

    func decodeCOSEPayload(_ data: Data) -> Result<CBOR, HealthCertificateDecodingError> {
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
            case let CBOR.byteString(payloadBytes) = message[2],
            let payload = try? CBOR.decode(payloadBytes) else {

            return .failure(.HC_COSE_MESSAGE_INVALID)
        }

        return .success(payload)
    }

    func extractJSON(_ cbor: CBOR) throws -> Data {
        guard case let .map(map) = cbor else {
            throw HealthCertificateDecodingError.HC_CBOR_DECODING_FAILED
        }
        return try JSONSerialization.data(withJSONObject: map.anyMap)
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

    public func fetchProofCertificate(for healthCertificates: [CertificateRepresentations], completion: (FetchProofCertificateResult) -> Void) {
        completion(fetchProofCertificateResult)
    }

    // MARK: - Private

    private let decodeResult: DecodeHealthCertificateResult
    private let fetchProofCertificateResult: FetchProofCertificateResult

}
