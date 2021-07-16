//
// 🦠 Corona-Warn-App
//

import Foundation

public protocol DCCSignatureVerifying {
    func verify(certificate base45: Base45, with signingCertificates: [DCCSigningCertificate], and validationClock: Date) -> Result<Void, DCCSignatureVerificationError>
}

public struct DCCSignatureVerification: DCCSignatureVerifying {

    public init() { }

    public func verify(certificate base45: Base45, with signingCertificates: [DCCSigningCertificate], and validationClock: Date = Date()) -> Result<Void, DCCSignatureVerificationError> {

        return .success(())
    }
}

public struct DCCSignatureVerifyingStub: DCCSignatureVerifying {

    let error: DCCSignatureVerificationError?

    public init(error: DCCSignatureVerificationError?) {
        self.error = error
    }

    public func verify(certificate base45: Base45, with signingCertificates: [DCCSigningCertificate], and validationClock: Date = Date()) -> Result<Void, DCCSignatureVerificationError> {
        if let error = error {
            return .failure(error)
        } else {
            return .success(())
        }
    }
}
