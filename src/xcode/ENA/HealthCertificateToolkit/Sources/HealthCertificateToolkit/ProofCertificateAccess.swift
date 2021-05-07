//
// 🦠 Corona-Warn-App
//

import Foundation

public typealias CBORData = Data

public struct ProofCertificateAccess {

    // MARK: - Init

    public init() {}

    // MARK: - Public

    public func extractCBORWebTokenHeader(from cborData: CBORData) -> Result<CBORWebTokenHeader, CertificateDecodingError> {
        return certificateAccess.extractHeader(from: cborData)
    }
 
    public func extractDigitalGreenCertificate(from cborData: CBORData) -> Result<DigitalGreenCertificate, CertificateDecodingError> {
        return certificateAccess.extractDigitalGreenCertificate(from: cborData)
    }

    public func fetchProofCertificate(for healthCertificates: [Base45], completion: @escaping (Result<CBORData, ProofCertificateFetchingError>) -> Void) {
        completion(.success(CBORData()))
    }

    // MARK: - Internal

    let certificateAccess = CertificateAccess()
}
