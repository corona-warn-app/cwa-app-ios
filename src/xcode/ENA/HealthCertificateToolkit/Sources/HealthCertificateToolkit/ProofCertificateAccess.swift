//
// 🦠 Corona-Warn-App
//

import Foundation

public struct ProofCertificateAccess {

    // MARK: - Public

    public func extractCBORWebTokenHeader(cbor: Data) -> Result<CBORWebTokenHeader, CertificateDecodingError> {
        return certificateAccess.extractHeader(from: cbor)
    }

    public func extractDigitalGreenCertificate(cbor: Data) -> Result<DigitalGreenCertificate, CertificateDecodingError> {
        return certificateAccess.extractDigitalGreenCertificate(from: cbor)
    }

    public func fetchProofCertificate(for healthCertificates: [String]) -> Result<Data, ProofCertificateFetchingError> {

        return.success(Data())
    }

    // MARK: - Internal

    let certificateAccess = CertificateAccess()
}
