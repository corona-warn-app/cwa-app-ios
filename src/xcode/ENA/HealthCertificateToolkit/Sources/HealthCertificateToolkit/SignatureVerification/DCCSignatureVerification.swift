//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftCBOR
import Security
import ASN1Decoder

public protocol DCCSignatureVerifying {
    func verify(certificate base45: Base45, with signingCertificates: [DCCSigningCertificate], and validationClock: Date) -> Result<Void, DCCSignatureVerificationError>

    func validUntilDate(certificate base45: Base45, with signingCertificates: [DCCSigningCertificate]) -> Result<Date, DCCSignatureVerificationError>
}

public struct DCCSignatureVerification: DCCSignatureVerifying {

    // MARK: - Init

    public init() { }

    // MARK: - Protocol DCCSignatureVerifying

    // swiftlint:disable cyclomatic_complexity
    public func verify(certificate base45: Base45, with signingCertificates: [DCCSigningCertificate], and validationClock: Date = Date()) -> Result<Void, DCCSignatureVerificationError> {

        // Find matching DSC

        let certificateResult = DigitalCovidCertificateAccess().extractDigitalCovidCertificate(from: base45)
        guard case let .success(certificate) = certificateResult else {
            if case let .failure(error) = certificateResult {
                return .failure(.HC_CBOR_DECODING_FAILED(error))
            }
            fatalError("Success and failure where handled, this part should never be reaached.")
        }

        let matchingSigningCertificateResult = findMatchingSigningCertificate(certificate: base45, with: signingCertificates)
        guard case let .success(matchingSigningCertificate) = matchingSigningCertificateResult  else {
            if case let .failure(error) = matchingSigningCertificateResult {
                return .failure(error)
            }
            fatalError("Success and failure where handled, this part should never be reaached.")
        }

        // Check DSC validity

        guard let x509Certificate = try? X509Certificate(data: matchingSigningCertificate.data),
              let notBefore = x509Certificate.notBefore,
              let notAfter = x509Certificate.notAfter else {
            return .failure(.HC_DSC_NOT_READABLE)
        }
        if notBefore > validationClock {
            return .failure(.HC_DSC_NOT_YET_VALID)
        }
        if notAfter < validationClock {
            return .failure(.HC_DSC_EXPIRED)
        }

        // Check extended key usage

        if x509Certificate.extendedKeyUsage.isEmpty {
            return .success(())
        }

        let containsAnyKeyUsage = x509Certificate.extendedKeyUsage.contains {
            return ExtendedKeyUsageObjectIdentifier.all.contains($0)
        }
        if !containsAnyKeyUsage {
            return .success(())
        }

        switch certificate.type {
        case .vaccination:
            let containsAnyVaccinationCertificateKeyUsage = x509Certificate.extendedKeyUsage.contains {
                return ExtendedKeyUsageObjectIdentifier.vaccinationIssuer.contains($0)
            }
            return containsAnyVaccinationCertificateKeyUsage ? .success(()) : .failure(.HC_DSC_OID_MISMATCH_VC)
        case .test:
            let containsAnyTestCertificateKeyUsage = x509Certificate.extendedKeyUsage.contains {
                return ExtendedKeyUsageObjectIdentifier.testIssuer.contains($0)
            }
            return containsAnyTestCertificateKeyUsage ? .success(()) : .failure(.HC_DSC_OID_MISMATCH_TC)
        case .recovery:
            let containsAnyRecoveryCertificateKeyUsage = x509Certificate.extendedKeyUsage.contains {
                return ExtendedKeyUsageObjectIdentifier.recoveryIssuer.contains($0)
            }
            return containsAnyRecoveryCertificateKeyUsage ? .success(()) : .failure(.HC_DSC_OID_MISMATCH_RC)
        }
    }

    public func validUntilDate(certificate base45: Base45, with signingCertificates: [DCCSigningCertificate]) -> Result<Date, DCCSignatureVerificationError> {

        // Find matching DSC and return validUntilDate

        let matchingSigningCertificateResult = findMatchingSigningCertificate(certificate: base45, with: signingCertificates)
        guard case let .success(matchingSigningCertificate) = matchingSigningCertificateResult  else {
            if case let .failure(error) = matchingSigningCertificateResult {
                return .failure(error)
            }
            fatalError("Success and failure where handled, this part should never be reaached.")
        }

        guard let x509Certificate = try? X509Certificate(data: matchingSigningCertificate.data),
              let notAfter = x509Certificate.notAfter else {
            return .failure(.HC_DSC_NOT_READABLE)
        }

        return .success(notAfter)
    }

    // MARK: - Private

    private enum Algorithm: Int {
        case ES256 = -7
        case PS256 = -37

        var secKeyAlgorithm: SecKeyAlgorithm {
            switch self {
            case .ES256:
                return .ecdsaSignatureMessageX962SHA256
            case .PS256:
                return .rsaSignatureMessagePSSSHA256
            }
        }
    }

    private func determineAlgorithm(from coseEntries: [CBOR]) -> Result<Algorithm, DCCSignatureVerificationError> {
        guard case let .byteString(protectedHeaderBytes) = coseEntries[0],
           let protectedHeaderCBOR = try? CBORDecoder(input: protectedHeaderBytes).decodeItem(),
           case let .negativeInt(algorithmIdentifier) = protectedHeaderCBOR[1] else {
            return .failure(.HC_COSE_UNKNOWN_ALG)
        }

        // I know its confusing. Please see here how negative integers are handled for CBOR (Major type 1:  a negative integer.): https://datatracker.ietf.org/doc/html/rfc7049#section-2.1
        // And here some rationale for this kind of implementation: https://stackoverflow.com/questions/50584127/rationale-for-cbor-negative-integers
        guard let algorithm = Algorithm(rawValue: -1 - Int(algorithmIdentifier)) else {
            return .failure(.HC_COSE_NO_ALG)
        }

        return .success(algorithm)
    }

    private func extractProtectedHeader(from coseEntries: [CBOR]) -> Result<[UInt8], DCCSignatureVerificationError> {
        guard case let .byteString(protectedHeaderBytes) = coseEntries[0] else {
            return .failure(.HC_COSE_UNKNOWN_ALG)
        }
        return .success(protectedHeaderBytes)
    }

    private func findMatchingSigningCertificate(certificate base45: Base45, with signingCertificates: [DCCSigningCertificate]) -> Result<DCCSigningCertificate, DCCSignatureVerificationError> {

        // Decode and extract COSE headers

        let coseEntriesResult = DigitalCovidCertificateAccess().extractCOSEEntries(from: base45)
        guard case let .success(coseEntries) = coseEntriesResult  else {
            if case let .failure(error) = coseEntriesResult {
                return .failure(.HC_CBOR_DECODING_FAILED(error))
            }
            fatalError("Success and failure where handled, this part should never be reaached.")
        }
        guard case let .byteString(protectedHeaderBytes) = coseEntries[0] else {
            return .failure(.HC_COSE_PH_INVALID)
        }
        guard case let .byteString(payloadBytes) = coseEntries[2] else {
            return .failure(.HC_CBOR_DECODING_FAILED(.HC_COSE_MESSAGE_INVALID))
        }
        guard case let .byteString(signature) = coseEntries[3] else {
            return .failure(.HC_COSE_NO_SIGN1)
        }

        // Extract 'kid'

        var keyIdentifier: Data?
        if case let .success(kidBase64) = DigitalCovidCertificateAccess().extractKeyIdentifier(from: coseEntries),
           let kid = Data(base64Encoded: kidBase64) {
            keyIdentifier = kid
        }

        // Determine 'alg'

        let algorithmResult = determineAlgorithm(from: coseEntries)
        guard case let .success(algorithm) = algorithmResult else {
            if case let .failure(error) = algorithmResult {
                return .failure(error)
            }
            fatalError("Success and failure where handled, this part should never be reaached.")
        }

        // Determine 'signed payload'

        let signedPayload = CBOR.array([
            "Signature1",
            CBOR.byteString(protectedHeaderBytes),
            CBOR.byteString([UInt8]()),
            CBOR.byteString(payloadBytes)
        ]).encode()

        // Determine 'verifier'

        let verifier: Data
        switch algorithm {
        case .PS256:
            verifier = Data(signature)
        case .ES256:
            guard let ecdsaSignature = ECDSA.convertSignatureData(Data(signature)) else {
                return .failure(.HC_COSE_ECDSA_SPLITTING_FAILED)
            }
            verifier = Data(ecdsaSignature)
        }

        // Filter DSCs for 'DSCs to test'

        let matchedSigningCertificates = signingCertificates.filter {
            $0.kid == keyIdentifier
        }
        let signingCertificatesToTest = matchedSigningCertificates.isEmpty ? signingCertificates : matchedSigningCertificates

        // Find 'DSC for DGC'

        var _passedSigningCertificate: DCCSigningCertificate?

        for signingCertificateToTest in signingCertificatesToTest {
            guard let publicKey = signingCertificateToTest.publicKey else {
                continue
            }

            var error: Unmanaged<CFError>?
            let success = SecKeyVerifySignature(
                publicKey,
                algorithm.secKeyAlgorithm,
                Data(signedPayload) as CFData,
                verifier as CFData,
                &error
            )
            if error != nil {
                continue
            }
            if success {
                _passedSigningCertificate = signingCertificateToTest
                break
            }
        }
        guard let passedSigningCertificate = _passedSigningCertificate else {
            return .failure(.HC_DSC_NO_MATCH)
        }

        return .success(passedSigningCertificate)
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

extension DigitalCovidCertificate {

    enum CertificateType {
        case vaccination
        case test
        case recovery
    }

    var type: CertificateType {
        if isVaccinationCertificate {
            return .vaccination
        } else if isTestCertificate {
            return .test
        } else if isRecoveryCertificate {
            return .recovery
        } else {
            fatalError("The certificate has to have either VC, TC or RC entries.")
        }
    }

    var isVaccinationCertificate: Bool {
        guard let vaccinationEntries = vaccinationEntries else {
            return false
        }
        return !vaccinationEntries.isEmpty
    }

    var isTestCertificate: Bool {
        guard let testEntries = testEntries else {
            return false
        }
        return !testEntries.isEmpty
    }

    var isRecoveryCertificate: Bool {
        guard let recoveryEntries = recoveryEntries else {
            return false
        }
        return !recoveryEntries.isEmpty
    }
}
