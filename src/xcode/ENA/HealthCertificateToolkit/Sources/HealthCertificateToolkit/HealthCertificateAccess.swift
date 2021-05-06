//
// 🦠 Corona-Warn-App
//

import Foundation
import base45_swift

public typealias Base45 = String

public struct HealthCertificateAccess {

    // MARK: - Public

    public func extractCBORWebTokenHeader(from base45: Base45) -> Result<CBORWebTokenHeader, CertificateDecodingError> {
        let cborDataResult = extractCBOR(from: base45)

        switch cborDataResult {
        case let .success(cborData):
            return certificateAccess.extractHeader(from: cborData)
        case let .failure(error):
            return .failure(error)
        }
    }

    public func extractHealthCertificate(from base45: Base45) -> Result<DigitalGreenCertificate, CertificateDecodingError> {
        let cborDataResult = extractCBOR(from: base45)

        switch cborDataResult {
        case let .success(cborData):
            return certificateAccess.extractDigitalGreenCertificate(from: cborData)
        case let .failure(error):
            return .failure(error)
        }
    }

    // MARK: - Internal

    var certificateAccess = CertificateAccess()

    func extractCBOR(from base45: Base45) -> Result<CBORData, CertificateDecodingError> {
        guard let zipData = try? base45.fromBase45() else {
            return .failure(.HC_BASE45_DECODING_FAILED)
        }

        guard let cborData =  try? zipData.decompressZLib() else {
            return .failure(.HC_ZLIB_DECOMPRESSION_FAILED)
        }

        return .success(cborData)
    }
}
