//
// 🦠 Corona-Warn-App
//


import Foundation
import Compression

public typealias DecodeHealthCertificateResult = Result<HealthCertificateRepresentations, HealthCertificateDecodingError>
public typealias FetchProofCertificateResult = Result<Data, ProofCertificateFetchingError>

public enum ProofCertificateFetchingError: Error {
    case something
    case general
}

public enum HealthCertificateDecodingError: Error {
    case something
    case general
}

public protocol HealthCertificateToolkitProtocol {

    func decodeHealthCertificate(base45: String) -> DecodeHealthCertificateResult

    func fetchProofCertificate(for healthCertificates: [HealthCertificateRepresentations], completion: (FetchProofCertificateResult) -> Void)
}

public struct HealthCertificateToolkit: HealthCertificateToolkitProtocol {

    // MARK: - Protocol HealthCertificateToolkitProtocol

    public func decodeHealthCertificate(base45: String) -> DecodeHealthCertificateResult {
        .success( .fake())
    }

    public func fetchProofCertificate(for healthCertificates: [HealthCertificateRepresentations], completion: (FetchProofCertificateResult) -> Void) {

    }

    // MARK: - Internal

    func decodeWithBase45(_ base45String: String) -> Data {
        return Data()
    }

    func decompress(_ data: Data) -> Data {
        return Data()
    }

    func decodeCOSEPayload(_ data: Data) -> Data {
        return Data()
    }

    func decodeJSON(_ data: Data) -> Data {
        return Data()
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

    public func fetchProofCertificate(for healthCertificates: [HealthCertificateRepresentations], completion: (Result<Data, ProofCertificateFetchingError>) -> Void) {
        completion(fetchProofCertificateResult)
    }

    // MARK: - Private

    private let decodeResult: DecodeHealthCertificateResult
    private let fetchProofCertificateResult: FetchProofCertificateResult

}
