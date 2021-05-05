//
// 🦠 Corona-Warn-App
//

import Foundation
import base45_swift

public struct HealthCertificateAccess {

    // MARK: - Public

    public func extractCBORWebTokenHeader(base45: String) -> Result<CBORWebTokenHeader, HealthCertificateDecodingError> {
        let cborDataResult = extractCBOR(base45: base45)

        guard case let .success(cborData) = cborDataResult else {
            if case let .failure(error) = cborDataResult {
                return .failure(error)
            } else {
                fatalError("Has to be an error at this point.")
            }
        }

        return certificateAccess.extractHeader(cborData)
    }

    public func extractHealthCertificate(base45: String) -> Result<HealthCertificate, HealthCertificateDecodingError> {
        let cborDataResult = extractCBOR(base45: base45)

        guard case let .success(cborData) = cborDataResult else {
            if case let .failure(error) = cborDataResult {
                return .failure(error)
            } else {
                fatalError("Has to be an error at this point.")
            }
        }

        return certificateAccess.extractHealthCertificate(cborData)
    }

    // MARK: - Internal

    private var certificateAccess = CertificateAccess()

    private func extractCBOR(base45: String) -> Result<Data, HealthCertificateDecodingError> {
        guard let zipData = try? base45.fromBase45() else {
            return .failure(.HC_BASE45_DECODING_FAILED)
        }

        guard let cborData =  try? zipData.decompressZLib() else {
            return .failure(.HC_ZLIB_DECOMPRESSION_FAILED)
        }

        return .success(cborData)
    }
}
