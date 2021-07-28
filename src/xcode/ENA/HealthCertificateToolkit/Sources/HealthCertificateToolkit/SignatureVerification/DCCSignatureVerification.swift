//
// 🦠 Corona-Warn-App
//

import Foundation

public protocol DCCSignatureVerifying {
    func verify(certificate base45: Base45, with signingCertificates: [DCCSigningCertificate], and validationClock: Date) -> Result<Void, DCCSignatureVerificationError>

    func validUntilDate(certificate base45: Base45, with signingCertificates: [DCCSigningCertificate]) -> Result<Date, DCCSignatureVerificationError>
}

public struct DCCSignatureVerification: DCCSignatureVerifying {

    public init() { }

    public func verify(certificate base45: Base45, with signingCertificates: [DCCSigningCertificate], and validationClock: Date = Date()) -> Result<Void, DCCSignatureVerificationError> {

        return .success(())
    }

    public func validUntilDate(certificate base45: Base45, with signingCertificates: [DCCSigningCertificate]) -> Result<Date, DCCSignatureVerificationError> {
        return .success(Date())
    }
}

public struct DCCSignatureVerifyingStub: DCCSignatureVerifying {

    let error: DCCSignatureVerificationError?
    let validationUntilDate: Date
    let validationUntilDateError: DCCSignatureVerificationError?

    public init(
        error: DCCSignatureVerificationError? = nil,
        validationUntilDate: Date = Date(),
        validationUntilDateError: DCCSignatureVerificationError? = nil
    ) {
        self.error = error
        self.validationUntilDate = validationUntilDate
        self.validationUntilDateError = validationUntilDateError
    }

    public func verify(certificate base45: Base45, with signingCertificates: [DCCSigningCertificate], and validationClock: Date = Date()) -> Result<Void, DCCSignatureVerificationError> {
        if let error = error {
            return .failure(error)
        } else {
            return .success(())
        }
    }

    public func validUntilDate(certificate base45: Base45, with signingCertificates: [DCCSigningCertificate]) -> Result<Date, DCCSignatureVerificationError> {
        if let validationUntilDateError = validationUntilDateError {
            return .failure(validationUntilDateError)
        } else {
            return .success(validationUntilDate)
        }
    }
}
