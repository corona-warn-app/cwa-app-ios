//
// 🦠 Corona-Warn-App
//

import Foundation
import base45_swift

public struct HealthCertificateAccess {

    // MARK: - Public

    public func extractCBORWebTokenHeader(base45: String) -> Result<CBORWebTokenHeader, HealthCertificateDecodingError> {
        let cborDataResult = extractCBOR(base45: base45)

        switch cborDataResult {
        case let .success(cborData):
            return certificateAccess.extractHeader(from: cborData)
        case let .failure(error):
            return .failure(error)
        }
    }

    public func extractHealthCertificate(base45: String) -> Result<DigitalGreenCertificate, HealthCertificateDecodingError> {
        let cborDataResult = extractCBOR(base45: base45)

        switch cborDataResult {
        case let .success(cborData):
            return certificateAccess.extractHealthCertificate(from: cborData)
        case let .failure(error):
            return .failure(error)
        }
    }

    // MARK: - Internal

    var certificateAccess = CertificateAccess()

    func extractCBOR(base45: String) -> Result<Data, HealthCertificateDecodingError> {
        guard let zipData = try? base45.fromBase45() else {
            return .failure(.HC_BASE45_DECODING_FAILED)
        }

        guard let cborData =  try? zipData.decompressZLib() else {
            return .failure(.HC_ZLIB_DECOMPRESSION_FAILED)
        }

        return .success(cborData)
    }
}
