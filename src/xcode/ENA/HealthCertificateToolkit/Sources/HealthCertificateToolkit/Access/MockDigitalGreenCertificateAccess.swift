//
// 🦠 Corona-Warn-App
//

import Foundation

public struct MockDigitalGreenCertificateAccess: DigitalGreenCertificateAccessProtocol {

    // MARK: - Init

    public init() {}

    // MARK: - Public

    public var extractedCBORWebTokenHeader: Result<CBORWebTokenHeader, CertificateDecodingError>?
    public var extractedDigitalGreenCertificate: Result<DigitalGreenCertificate, CertificateDecodingError>?
    public var convertedToBase45: Result<Base45, CertificateDecodingError>?

    public func extractCBORWebTokenHeader(from base45: Base45) -> Result<CBORWebTokenHeader, CertificateDecodingError> {
        guard let extractedCBORWebTokenHeader = extractedCBORWebTokenHeader else {
            return .success(CBORWebTokenHeader.fake())
        }

        return extractedCBORWebTokenHeader
    }

    public func extractDigitalGreenCertificate(from base45: Base45) -> Result<DigitalGreenCertificate, CertificateDecodingError> {
        guard let extractedDigitalGreenCertificate = extractedDigitalGreenCertificate else {
            return .success(DigitalGreenCertificate.fake())
        }

        return extractedDigitalGreenCertificate
    }

    public func convertToBase45(from base64: Base64, with dataEncryptionKey: Data) -> Result<Base45, CertificateDecodingError> {
        guard let convertedToBase45 = convertedToBase45 else {
            return DigitalGreenCertificateFake.makeBase45Fake(
                from: DigitalGreenCertificate.fake(),
                and: CBORWebTokenHeader.fake()
            )
        }

        return convertedToBase45
    }

}
