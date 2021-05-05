//
// 🦠 Corona-Warn-App
//

import Foundation

public struct ProofCertificateAccess {

    // MARK: - Public

    public func extractCBORWebTokenHeader(cbor: Data) -> Result<CBORWebTokenHeader, HealthCertificateDecodingError> {
        return certificateAccess.extractHeader(from: cbor)
    }

    public func extractHealthCertificate(cbor: Data) -> Result<DigitalGreenCertificate, HealthCertificateDecodingError> {
        return certificateAccess.extractHealthCertificate(from: cbor)
    }

    public func fetchProofCertificate(for healthCertificates: [String]) -> Result<Data, ProofCertificateFetchingError> {

        return.success(Data())
    }

    // MARK: - Internal

    let certificateAccess = CertificateAccess()
}
