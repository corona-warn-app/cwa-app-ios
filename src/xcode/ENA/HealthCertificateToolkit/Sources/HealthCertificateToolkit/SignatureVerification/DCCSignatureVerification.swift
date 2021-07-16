//
// 🦠 Corona-Warn-App
//

import Foundation

public protocol DCCSignatureVerifiable {
    func verify(certificate base45: Base45, with signingCertificates: [DCCSigningCertificate], and validationClock: Date) -> Result<Void, DCCSignatureVerificationError>
}

public struct DCCSignatureVerification: DCCSignatureVerifiable {

    public init() { }

    public func verify(certificate base45: Base45, with signingCertificates: [DCCSigningCertificate], and validationClock: Date = Date()) -> Result<Void, DCCSignatureVerificationError> {

        return .success(())
    }
}

public struct DCCSignatureVerifiableStub {

    let error: DCCSignatureVerificationError?

    public init(error: DCCSignatureVerificationError?) {
        self.error = error
    }

    func verify(certificate base45: Base45, with signingCertificates: [DCCSigningCertificate], and validationClock: Date = Date()) -> Result<Void, DCCSignatureVerificationError> {
        if let error = error {
            return .failure(error)
        } else {
            return .success(())
        }
    }
}
