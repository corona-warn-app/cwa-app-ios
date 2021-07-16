//
// 🦠 Corona-Warn-App
//

import Foundation

public protocol DCCSignatureVerifiable {
    func verify(certificate base45: Base45, with signingCertificates: [SigningCertificate], and validationClock: Date) -> Result<Void, SignatureVerificationError>
}

public struct DCCSignatureVerification: DCCSignatureVerifiable {

    public init() { }

    public func verify(certificate base45: Base45, with signingCertificates: [SigningCertificate], and validationClock: Date = Date()) -> Result<Void, SignatureVerificationError> {

        let coseEntriesResult = DigitalCovidCertificateAccess().extractCOSEEntries(from: base45)


        return .success(())
    }
}

public struct DCCSignatureVerifiableStub {

    let error: SignatureVerificationError?

    public init(error: SignatureVerificationError?) {
        self.error = error
    }

    func verify(certificate base45: Base45, with signingCertificates: [SigningCertificate], and validationClock: Date = Date()) -> Result<Void, SignatureVerificationError> {
        if let error = error {
            return .failure(error)
        } else {
            return .success(())
        }
    }
}
