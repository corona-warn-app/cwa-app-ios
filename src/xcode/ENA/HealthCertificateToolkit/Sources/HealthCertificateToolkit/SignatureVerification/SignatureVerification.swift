//
// 🦠 Corona-Warn-App
//

import Foundation

protocol SignatureVerifiable {
    func verify(certificate base45: Base45, with signingCertificates: [Data], and validationClock: Date) -> Result<Void, SignatureVerificationError>
}

struct SignatureVerification: SignatureVerifiable {

    func verify(certificate base45: Base45, with signingCertificates: [Data], and validationClock: Date = Date()) -> Result<Void, SignatureVerificationError> {
        return .success(())
    }
}

struct SignatureVerifiableStub {

    let error: SignatureVerificationError?

    func verify(certificate base45: Base45, with signingCertificates: [Data], and validationClock: Date = Date()) -> Result<Void, SignatureVerificationError> {
        if let error = error {
            return .failure(error)
        } else {
            return .success(())
        }
    }
}
