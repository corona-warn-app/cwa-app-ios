//
// 🦠 Corona-Warn-App
//

import Foundation

public struct MockDigitalCovidCertificateAccess: DigitalCovidCertificateAccessProtocol {

    // MARK: - Init

    public init() {}

    // MARK: - Public
    
    public var extractedCBORWebTokenHeader: Result<CBORWebTokenHeader, CertificateDecodingError>?
    public var extractedDigitalCovidCertificate: Result<DigitalCovidCertificate, CertificateDecodingError>?
    public var convertedToBase45: Result<Base45, CertificateDecodingError>?

    public func extractCertificateComponents(from base45: Base45) -> Result<DigitalCovidCertificateComponents, CertificateDecodingError> {
        .success(DigitalCovidCertificateComponents(
            header: CBORWebTokenHeader.fake(),
            certificate: DigitalCovidCertificate.fake(),
            keyIdentifier: "",
            signature: Data(),
            algorithm: .ES256
        ))
    }
    
    public func extractCBORWebTokenHeader(from base45: Base45) -> Result<CBORWebTokenHeader, CertificateDecodingError> {
        guard let extractedCBORWebTokenHeader = extractedCBORWebTokenHeader else {
            return .success(CBORWebTokenHeader.fake())
        }

        return extractedCBORWebTokenHeader
    }

    public func extractDigitalCovidCertificate(from base45: Base45) -> Result<DigitalCovidCertificate, CertificateDecodingError> {
        guard let extractedDigitalCovidCertificate = extractedDigitalCovidCertificate else {
            return .success(DigitalCovidCertificate.fake())
        }

        return extractedDigitalCovidCertificate
    }

    public func convertToBase45(from base64: Base64, with dataEncryptionKey: Data) -> Result<Base45, CertificateDecodingError> {
        guard let convertedToBase45 = convertedToBase45 else {
            return DigitalCovidCertificateFake.makeBase45Fake(
                certificate: DigitalCovidCertificate.fake(),
                header: CBORWebTokenHeader.fake()
            )
        }

        return convertedToBase45
    }

}
