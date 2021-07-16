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

        let coseEntriesResult = DigitalCovidCertificateAccess().extractCOSEEntries(from: base45)

        guard case let .success(coseEntries) = coseEntriesResult else {
            if case let .failure(error) = coseEntriesResult {
                return .failure(.HC_CBOR_DECODING_FAILED(error))
            }
            fatalError("Success and failure where handled, this part should never be reaached.")
        }

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
